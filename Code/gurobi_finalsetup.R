rm(list=ls())

## Windows
install.packages("C:/gurobi810/win64/R/gurobi_8.1-0.zip", repos = NULL)
## Mac 
#install.packages('/Library/gurobi810/mac64/R/gurobi_8.1-0.tgz', repos=NULL) 
## Linux
#install.packages(file.path(Sys.getenv('GUROBI_HOME'), 'R/gurobi_8.1-0_R_x86_64-pc-linux-gnu.tar.gz'), repos = NULL)

install.packages("slam")

## Gurobi test
library(gurobi)
model <- list()
model$obj <- c(1, 1, 2)
model$modelsense <- "max"
model$rhs <- c(4, 1)
model$sense <- c("<", ">")
model$vtype <- "B"
model$A <- matrix(c(1, 2, 3, 1, 1, 0), nrow = 2, ncol = 3, byrow = TRUE)
result <- gurobi(model, list())

## Other packages
install.packages(c("nloptr", "nleqslv", "microbenchmark", "Rglpk", "magick", "igraph", "tidyverse", "rgdal", "rdist", "tranport", "geometry"))
install.packages("devtools")

## Run during the break!
library("devtools")
#install_github("TraME-Project/Rgeogram")
#install_github('TraME-Project/TraME-R') install_github('TraME-Project/Shortest-Path-R')
#install_github("collectivemedia/tictoc")