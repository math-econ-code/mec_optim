# A quick tutorial on the HPC

The high performance computing resources of NYU are super useful for researchers. If you are doing large compute jobs you are able to access more resources than you probably have access to on your local machine (including GPU resources). Also working remotely allows you free up your local machine for important, non-compute activities without having to worry about a crash ruining your work.

A guide to the HPC is found on the [HPC wiki](https://wikis.nyu.edu/). Unfortunately the HPC wiki isn't the greatest resource and often relies on quite a bit of presumed knowledge (in particular you need to be quite comfortable using a terminal).

So hopefully this guide will help.

Alfred has told me that you all have access to the HPC already. For anyone who doesn't you can find out how [here](https://wikis.nyu.edu/display/NYUHPC/Getting+or+renewing+an+HPC+account). Note that you need to get a faculty sponsor to do this, so plan ahead.

In order to access the HPC cluster we will need to `ssh` onto the cluster. We will need to make sure that you can use `ssh` and `X`.
* **Windows**

    You can use PuTTy (see the instructions [here](https://wikis.nyu.edu/display/NYUHPC/Accessing+HPC+clusters+from+Windows+workstation)).

    However we already have Git Bash installed so we only need to add `X`. I recommend installing [VcXsrv](https://sourceforge.net/projects/vcxsrv/files/).

    Then in your `$HOME` directory, create a `.bash_profile` and write 
    ```
    export DISPLAY=localhost:0.0
    ```
    Then restart your git-bash.

* **Nix**

    If you have Linux you already have `X` installed. For OSX user make sure to install [XQuartz](http://xquartz.macosforge.org/landing/)

# SSH Tunnel

When are connecting from outside of the NYU network it will be best to set up an SSH tunnel. This will make it easy for us to transfer files to and from the clusters.

In our home directory we want to open our `.ssh` folder (or make one using `mkdir .ssh`) and open the `config` file. In the `config` file add
```
# first we create the tunnel, with instructions to pass incoming
# packets on ports 8024, 8025 and 8026 through it and to specific
# locations

Host hpcgwtunnel
   HostName gw.hpc.nyu.edu
   ForwardX11 no
   LocalForward 8025 dumbo.hpc.nyu.edu:22
   LocalForward 8026 prince.hpc.nyu.edu:22
   User NetID 

# next we create an alias for incoming packets on the port. The
# alias corresponds to where the tunnel forwards these packets

Host dumbo
  HostName localhost
  Port 8025
  ForwardX11 yes
  User NetID

Host prince
  HostName localhost
  Port 8026
  ForwardX11 yes
  User NetID
```
## Start tunnel 
```
ssh hpcgwtunnel
```
We need to leave this window open for our tunnel to remain open.

## Logging in via tunnel

Open a new terminal window and type

```
ssh -Y prince
```
# Jupyter 

Copy run-jupyter.sbatch example to your scratch directory:

``` 
mkdir /scratch/$USER/myjupyter
cp /share/apps/examples/jupyter/run-jupyter.sbatch /scratch/$USER/myjupyter
```

From your scratch directory on Prince submit run-jupyter.sbatch to job scheduler:

```
cd /scratch/<net_id>/myjupyter
sbatch run-jupyter.sbatch
```

In your scratch sub-directory on Prince find and open slurm-"job-number".out file
```
ls
less slurm-<job-number>.out
```
This will give us some instructions to follow. In essence we need to open up a new tunnel using
```
ssh -L 61125:localhost:61125 <NetID>@prince
```
Just a quick note of what is being done with this command here. The standard ssh syntax is 
```
ssh -L local_port:remote_address:remote_port username@server.com
```
So currently on the HPC, jupyter is being served at localhost:61125. So we are telling our local machine to take what is being served on the HPC at this port and forward it to our own 61125. Thus we can access this notebook at `http://localhost:61125/`, with the security token. i.e.
```
http://localhost:61125/?token=XXXXXXXX
```
The notebook will stay running until you shut it down
```
scancel <job-number>
```
If you don't know the job number you can find it (this will also show)
```
squeue -u $USER
```

### Asking for more resources

The default resources that you will have access to is a single node, with 2 CPUs and 2GB of memory. You can see this by reading 
```
less run-jupyter.sbatch
```
You can modify the number of resources by modifying this file
```
nano run-jupyter.sbatch
```
Note that if you ask for lots of resources you might not get them.

# Traditional HPC stuff

If you need to do something outside the Jupyter ecosystem then we will need to learn a couple of traditional remote tools.

### SCP

`scp` stands for Secure Copy Protocol and will allow us to copy things to the HCP from local machines. For Windows, you can use [WinSCP](https://winscp.net/eng/index.php) for a program with a nice graphical interface. However we will learn using the command line.

The syntax of scp is 
```
scp source destination
```
Because we set up our tunnel with aliases earlier this will be quite easy. Suppose we have a file `mat.m` that we want to copy to the cluster using
```
scp mat.m prince:/scratch/<NetID>
```

## Running a job

To access resources, we need to load them up using the `module` command. For example for `matlab` we can load it up by using

```
module load matlab/2019b
```
We can then open matlab by typing 
```
matlab
```
To find what modules are available, use
```
module spider
```
To list all modules, and you can append this with module to find more info, eg `module spider matlab` will list all the matlab versions.

But this point and click is not ideal for large jobs. Instead we will use a job scheduler `SLURM` ( Simple Linux Utility for Resource Management). 

Consider the following bash script `script.s`
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=5:00:00
#SBATCH --mem=2GB
#SBATCH --job-name=myTest
#SBATCH --mail-type=END
#SBATCH --mail-user=bob.smith@nyu.edu
#SBATCH --output=slurm_%j.out
  
module purge
module load stata/14.2
RUNDIR=$SCRATCH/my_project/run-${SLURM_JOB_ID/.*}
mkdir -p $RUNDIR
  
DATADIR=$SCRATCH/my_project/data
cd $RUNDIR
stata -b do $DATADIR/data_0706.do
```

Which annotated 

```bash
#!/bin/bash
# This line tells the shell how to execute this script, and is unrelated to SLURM. This is telling the shell that it this is a bash script.
   
# at the beginning of the script, lines beginning with "#SBATCH" are read by
# SLURM and used to set queueing options. You can comment out a SBATCH
# directive with a second leading #, eg:
##SBATCH --nodes=1
   
# we need 1 node, will launch a maximum of one task and use one cpu for the task: 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
   
# we expect the job to finish within 5 hours. If it takes longer than 5
# hours, SLURM can kill it:
#SBATCH --time=5:00:00
   
# we expect the job to use no more than 2GB of memory:
#SBATCH --mem=2GB
   
# we want the job to be named "myTest" rather than something generated
# from the script name. This will affect the name of the job as reported
# by squeue:
#SBATCH --job-name=myTest
 
# when the job ends, send me an email at this email address.
#SBATCH --mail-type=END
#SBATCH --mail-user=bob.smith@nyu.edu
   
# both standard output and standard error are directed to the same file.
# It will be placed in the directory I submitted the job from and will
# have a name like slurm_12345.out
#SBATCH --output=slurm_%j.out
  
# once the first non-comment, non-SBATCH-directive line is encountered, SLURM
# stops looking for SBATCH directives. The remainder of the script is  executed
# as a normal Unix shell script
  
# first we ensure a clean running environment:
module purge
# and load the module for the software we are using:
module load stata/14.2
  
# next we create a unique directory to run this job in. We will record its
# name in the shell variable "RUNDIR", for better readability.
# SLURM sets SLURM_JOB_ID to the job id, ${SLURM_JOB_ID/.*} expands to the job
# id up to the first '.' We make the run directory in our area under $SCRATCH, because at NYU HPC
# $SCRATCH is configured for the disk space and speed required by HPC jobs.
RUNDIR=$SCRATCH/my_project/run-${SLURM_JOB_ID/.*}
mkdir $RUNDIR
  
# we will be reading data in from somewhere, so define that too:
DATADIR=$SCRATCH/my_project/data
  
# the script will have started running in $HOME, so we need to move into the
# unique directory we just created
cd $RUNDIR
  
# now start the Stata job:
stata -b do $DATADIR/data_0706.do
```

We can submit this job using 
```
sbatch myscript.s
```
And we can monitor its progress using

```
squeue -u $USER
```

# Something for you to try
On your local machine create `mat.m` with 
```
x = rand(10000);

csvwrite('file.csv', x)
```
Copy this to the HPC into **YOUR** `scratch` directory.

Create a script file to run this. You can either create it locally and scp it or create it on the HPC using `nano <scriptname.s>`.

Request a short amount of time and few resources. To get matlab to run use on the last line of your bash script.

```
cat mat.m | srun matlab -nodisplay
```
Submit the job, check it is in the queue (wait a few seconds) and check the results.