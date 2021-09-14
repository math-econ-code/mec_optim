#################################################
##########  (c) by Alfred Galichon     ##########
#################################################

rm(list=ls())
require('Matrix')
require('gurobi')
thePath = getwd()
#thePath = "C:/Users/Alfred/Dropbox/Collaborations/__Teaching/matheconcode/_applications/04-appli-optassign"
#load('personalityMarriageData.RData')

data = as.matrix(read.csv(paste0(thePath,"/affinitymatrix.csv"),sep=",", header=TRUE)) # loads the data
nbcar = 10
A = matrix(as.numeric(data[1:nbcar,2:(nbcar+1)]),nbcar,nbcar)

data = as.matrix(read.csv(paste0(thePath,"/Xvals.csv"),sep=",", header=TRUE)) # loads the data
Xvals = matrix(as.numeric(data[,1:nbcar]),ncol=nbcar)

data = as.matrix(read.csv(paste0(thePath,"/Yvals.csv"),sep=",", header=TRUE)) # loads the data
Yvals = matrix(as.numeric(data[,1:nbcar]),ncol=nbcar)

sdX = apply(Xvals,2,sd)
sdY = apply(Yvals,2,sd)
mX = apply(Xvals,2,mean)
mY = apply(Yvals,2,mean)
Xvals = t( (t(Xvals)-mX) / sdX)
Yvals = t( (t(Yvals)-mY) / sdY)
nobs = dim(Xvals)[1]

Phi = Xvals %*% A %*% t(Yvals)

p = rep(1/nobs,nobs)
q = rep(1/nobs,nobs)

N = dim(Phi)[1]
M = dim(Phi)[2]

c = c(Phi)

A1 = kronecker(matrix(1,1,M),sparseMatrix(1:N,1:N))
A2 = kronecker(sparseMatrix(1:M,1:M),matrix(1,1,N))
A = rbind2(A1,A2)

d = c(p,q) 

result   = gurobi ( list(A=A,obj=c,modelsense="max",rhs=d,sense="="), params=list(OutputFlag=0) ) 
if (result$status=="OPTIMAL") {
  pi = matrix(result$x,nrow=N)
  u = result$pi[1:N]
  v = result$pi[(N+1):(N+M)]
  val = result$objval
} else {stop("optimization problem with Gurobi.") }

print(paste0("Value of the problem (Gurobi) =",val))
print(u[1:10])
print(v[1:10])

