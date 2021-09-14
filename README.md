# mec_optim_2020-01
‘math+econ+code’ masterclass on optimal transport and economic applications, NYU, Jan 20-24, 2020.

# Google form link
https://goo.gl/forms/5WLfkpc3GNCecd6A3

# Getting set up

In this course, we will primarily using R as our primary programming language. We will also have code available for Python and Julia, but these will be unsupported, so use at your own risk. The code will be presented using Jupyter notebooks, or you can run in RStudio. In addition we will using Gurobi, a commercial linear programming solver. The course will be hosted on github, and I encourage everyone to use git to pull from the repository. 

I will provide installation instructions for Windows and Mac users. If you are using Linux, I can trust you can figure it out.

## R and Rstudio

1. Go to the [R download page](https://cran.r-project.org/mirrors.html), choose whatever mirror you want and install.
2. Go to [RStudio download page](https://www.rstudio.com/products/rstudio/download/#download) and download and install.
3. Compilation of some packages
   1. Windows users should also install [Rtools](https://cran.r-project.org/bin/windows/Rtools/).
   2. Mac user should install Xcode and gfortran, the latter of which can be found [here](https://cran.r-project.org/bin/macosx/tools/).

## Anaconda (including Python)

1. Follow the installation instructions on the [Anaconda website](https://docs.anaconda.com/anaconda/install/), and download the Python 3.7 version.

2. For commands in `conda` Mac users can just use terminal, Windows users should open `Anaconda Prompt`.

3. Open `R` in `conda` by typing

   ```
   R
   ```

   If `R` is in your path, otherwise navigate there. Default for Windows is 

   ```
   cd "C:\Program Files\R\R-3.6.2\bin"
   ```

4. Install the R kernel 
    ```
    install.packages('IRkernel')
    IRkernel::installspec()
	```

5. Open Jupyter notebook using Anaconda Navigator or by typing 

   ```
   jupyter notebook
   ```

   in conda and open an `R` notebook.

## Gurobi

We will need a license to use Gurobi, (which is usually expensive), but there is a academic license that we can use.

1. Go to the [Gurobi downloads](http://www.gurobi.com/downloads/download-center) and click `Gurobi Optimizer`

2. You will need to create an 'Academic account'

3. After downloading, visit the [Free Academic License](http://www.gurobi.com/downloads/user/licenses/free-academic) page to request the free license. Follow the instructions in README.txt to install the software.

   Once installed, open your terminal and run `grbgetkey` using the  argument provided, e.g. 

   ```console
   grbgetkey ae36ac20-16e6-acd2-f242-4da6e765fa0a
   ```

	The `grbgetkey` program will prompt you to store the license key on  your machine, as well as validate your eligibility by confirming your  academic domain (e.g., any '.edu' address). 

   **Note:** you can only validate your license on the network of an academic institution. If you are trying this from home, you will need to use the [NYU VPN](https://www.nyu.edu/life/information-technology/getting-started/network-and-connectivity/vpn.html) (look for installation instructions in "Top Support articles". 

4. We will need to install some packages in R to get everything working nicely together, but we will save this for later.

## Git

1. Install git
   * **Mac users:** open terminal and run ```git --version```. If you don't have git installed, you will be prompted to do so.
   * **Windows users:** go to the [Git for Windows](https://gitforwindows.org/) download page and install. I recommend also installing [Visual Studio Code](https://code.visualstudio.com/) for a text editor, unless you already use SublimeText or vim. Alternatively [GitHub Desktop](https://desktop.github.com/) is a nice GUI for Git.

2. Open git

3. Navigate to your home directory

   * **Mac:**`cd /Users/user/my_project`
   * **Windows:** `cd /c/user/my_project`

4. Clone the mec_optim repo
   ```
     git clone https://github.com/math-econ-code/mec_optim_2020-01
   ```
5. Whenever the repository is updated 

   ```
     git pull origin master 
   ```
   This is only scratching the surface of what we can do with Git and GitHub. It is an amazing way to version control and collaborate on your code. There are lots of great tutorials on how to use both Git and GitHub and I strongly recommend you get into the habit of using it.

## Gurobi and R 

Once you have cloned the mec_optim repo, open `gurobi_finalsetup.R` (in the `setup_mec_optim` folder) in Rstudio and run the code.

## Gurobi and Python

Open `Anaconda Prompt` or `terminal` and navigate to the directory where gurobi installed. On windows, this is 
```
  cd  C:\gurobi900\win64
```
For Mac
```
cd /Library/gurobi900/mac64
```
Then type
```
  python setup.py install
```
