FROM fedora:31
# (c) Alfred Galichon (math+econ+code) with contributions from Keith O'Hara and Jules Baudet

RUN dnf install -y \
    which \
    file \
    tar \
    gzip \
    unzip \
    make \
    cmake \
    ninja-build \
    git \
    gcc \
    gcc-c++ \
    gfortran \
    gmp-devel \
    libtool \
    libcurl-devel \
    wget \
    libicu-devel \
    openssl-devel \
    zlib-devel \
    libxml2-devel \
    expat-devel \
    python3-devel \
    python3-pip

# set timezone
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# see: https://stackoverflow.com/questions/2720014/how-to-upgrade-all-python-packages-with-pip
RUN pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U

RUN pip3 install --upgrade wheel boto3 packaging networkx

RUN dnf install -y spatialindex-devel

RUN pip3 install osmnx



# RUN ln -s /usr/bin/python3 /usr/bin/python

# cleanup
RUN dnf clean all


RUN dnf install -y \
    boost-devel \
    swig \
    suitesparse-devel \
    eigen3-devel \
    CGAL-devel \
    CImg-devel  \
    openblas-devel

RUN pip3 install lxml && \
    pip3 install numpy pandas scipy matplotlib Pillow && \
    pip3 install jupyterlab

# libraries needed to build R (libXt-devel for X11)

RUN dnf install -y \
    xz-devel \
    bzip2-devel \
    libjpeg-turbo-devel \
    libpng-devel \
    cairo-devel \
    pcre-devel \
    java-latest-openjdk-devel \
    perl \
    libX11-devel \
    libXt-devel

# download and install R (but do not link with OpenBLAS)

ENV R_VERSION 4.0.2

RUN cd ~ && \
    curl -O --progress-bar https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz && \
    tar zxvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    ./configure --with-readline=no --with-x --with-cairo && \
    make && \
    make install

# install IRKernel

RUN dnf install -y czmq-devel

RUN echo -e "options(bitmapType = 'cairo', repos = c(CRAN = 'https://cran.rstudio.com/'))" > ~/.Rprofile
RUN R -e "install.packages(c('repr', 'IRdisplay', 'IRkernel'), type = 'source')"
RUN R -e "IRkernel::installspec(user = FALSE)"


# cleanup

RUN cd ~ && \
    rm -rf R-${R_VERSION} && \
    rm -f R-${R_VERSION}.tar.gz && \
    dnf clean all


# RUN cd ~ && mkdir ot_libs

# PyMongeAmpere 
# RUN cd ~/ot_libs && \
#    git clone https://github.com/mrgt/MongeAmpere.git && \
#    git clone https://github.com/mrgt/PyMongeAmpere.git && \
#    cd PyMongeAmpere && git submodule update --init --recursive && \
#    mkdir build && cd build && \
#    cmake -DCGAL_DIR=/usr/lib64/cmake/CGAL .. && \
#    make -j1
#
#
# Siconos
#RUN cd ~/ot_libs && \
#    git clone https://github.com/siconos/siconos.git && \
#    cd siconos && \
#    mkdir build && cd build && \
#    cmake .. && \
#    make -j1 && \
#    make install
#
# Siconos examples
#RUN cd ~/ot_libs && \
#    git clone https://github.com/siconos/siconos-tutorials.git 

RUN pip install pysdot

RUN mkdir -p /src/notebooks && \
    cd src/notebooks && \
    git clone https://github.com/math-econ-code/mec_optim_2021-01.git
    


# install Gurobi

ENV GUROBI_VERSION=9.1.1

RUN mkdir -p /home/gurobi/ && \
    cd /home/gurobi/ && \
    wget -P /home/gurobi/ http://packages.gurobi.com/${GUROBI_VERSION::-2}/gurobi${GUROBI_VERSION}_linux64.tar.gz && \
    tar xvfz /home/gurobi/gurobi${GUROBI_VERSION}_linux64.tar.gz && \
    mkdir -p /opt/gurobi && \
    mv /home/gurobi/gurobi911/linux64/ /opt/gurobi && \
    rm -rf /home/gurobi

ENV GUROBI_HOME="/opt/gurobi/linux64"
ENV PATH="${PATH}:${GUROBI_HOME}/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"


# install Gurobi R package

RUN R -e "install.packages(c('slam'), type = 'source')"

RUN cd /opt/gurobi/linux64/R && \
    tar xvfz gurobi_9.1-1_R_4.0.2.tar.gz && \
    R -e "install.packages('gurobi', repos = NULL)"



# Install NYU's floating license
# RUN cd /opt/gurobi && \
#	echo "TOKENSERVER=10.130.0.234" > gurobi.lic
#    # cd .. && cd .. && \
    

# install guropipy package
RUN python -m pip install -i https://pypi.gurobi.com gurobipy

# install tabulate
# cf https://stackoverflow.com/questions/31757552/trouble-importing-tabulate-in-python-3-4
RUN pip3 install tabulate

CMD cd src/notebooks/mec_optim_2021-01 && \
    git pull origin master && \
    cd .. && \
    jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root
    # ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

