# Getting started on AWS

This is a short guide on how to get the `mec optim` docker image spun up on AWS' computing platform EC2. This is also a nice introduction to using `ssh` (Secure Shell) and `scp` (Secure Copy).

## Create AWS account and launch EC2 instance

First create an account at AWS. This is free, and you can follow [this guide](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/).

Next we will need to launch an instance on EC2. Follow [this guide](https://docs.aws.amazon.com/quickstarts/latest/vmlaunch/step-1-launch-instance.html).

At step 7, save your key somewhere you can easily access it (for example on your desktop). Then in a terminal navigate to the folder (if you are on windows using wsl, recall that you need to use the prefix `/mnt/` to access the windows file system) where you saved your key, and enter 

```bash
cp myfirstkey.pem ~/.ssh/myfirstkey.pem
```

While we have a terminal open let's also change the permissions for our key (see this [link](https://chmodcommand.com/chmod-400/) to understand for what this command does)

```bash
chmod 400 ~/.ssh/myfirstkey.pem
```

In the webpage where we launched our instance, click `View Instances` to see a dashboard of the instances we have running. If we click on the instance we just opened, we will see a bunch of information. The thing that we care about here will be the `Public IPv4 DNS`, which you should copy.

Next we want to access our EC2 instance using `ssh`. We can do so 

```bash
ssh -i ~/.ssh/myfirstkey.pem ec2-user@public_dns_name
```

Where `public_dns_name` is the address we copied just before. You prompted `Are you sure you want to continue connecting (yes/no/[fingerprint])?`, type `yes`.

## Installing docker and setting up mec_optim image

Great! Now we have access to our EC2 instance. Let's follow some good practices and ensure the packages on the instance are up to date (note that Amazon Linux 2 is based on Red Hat Enterprise Linux and uses `yum` as its package manager)

```bash
sudo yum update -y
```

Let's install docker

```bash 
sudo amazon-linux-extras install docker
```

Start the docker service

```bash
sudo service docker start
```

Add the `ec2-user` to the `docker` group so you can execute Docker commands without using `sudo`                                       

```bash
sudo usermod -a -G docker ec2-user
```

Log out and log back in again to pick up the new `docker` group permissions, by typing `exit` and then repeated the `ssh` command from above. 

Verify that the `ec2-user` can run Docker commands without `sudo`                                     

```bash
docker info
```

Now we can pull the mec_optim image from docker hub

```bash
docker pull alfredgalichon/mec_optim:2021-01
```

Let's set up a directory that we can use as our persistent volume to attach

```bash
mkdir mec_optim
```

And a directory to store our license file

```bash
mkdir gurobi
```

Next we need to copy our gurobi license onto the EC2 instance. This can be done using `scp` in a terminal on our local machine 

```bash
scp -i ~/.ssh/myfirstkey.pem /path/to/your/license/gurobi.lic ec2-user@public_dns_name:/home/ec2-user/gurobi/gurobi.lic
```

Now we can launch our docker container 

```bash
docker run -it --rm -p 8888:8888 -v ~/mec_optim/volume:/src/notebooks/volume -v ~/gurobi/:/opt/gurobi/gurobi/ alfredgalichon/mec_optim:2021-01
```

This should output the standard jupyter notebook information. Take note of the token which is the `XXXX` in 

```
http://127.0.0.1:8888/?token=XXXX
```

Lastly, we want to take the jupyter notebook launched on EC2 and access using our local browser. We will do this by opening an `ssh` tunnel that maps the ports on the EC2 instance to our local machine. To open an `ssh` tunnel, in a new terminal (keeping your other terminal open) enter

 ```bash
ssh -i ~/.ssh/myfirstkey.pem -L 8888:localhost:8888 ec2-user@public_dns_name
 ```

Just a quick note of what is being done with this command here. The standard `ssh` tunnel syntax is (ignoring the `-i` argument)

```bash
ssh -L local_port:remote_address:remote_port username@server.com
```

So currently on the EC2 instance, jupyter is being served at `localhost:8888`.  So we are telling our local machine to take what is being served on EC2 on this port and forward it to our own port 8888. Now we can access this notebook on our local machine on port 8888 with the security token, i.e. enter

```
http://localhost:8888/?token=XXXXXXXX
```

into your web browser.

## Copying off the remote server

Suppose we have saved in the `volume` directory that we want to transfer back to our local machine. We can use `scp` again (on our local machine) but reverse the direction. e.g.

```bash
scp -i ~/.ssh/myfirstkey.pem ec2-user@public_dns_name:/home/ec2-user/mec_optim/volume/yourfile /path/to/whatever
```

## Spinning down your instance

Even the free tier instances will eventually begin costing money, so it is a good idea to stop your instance when it is not in use. This can be done on the EC2 instance dashboard we used earlier.