#################################################
###             Quantile Methods              ###
#################################################
##########       Alfred Galichon       ##########
#################################################
# References:
# R. Koenker, G. Bassett (1978): Regression Quantiles. Econometrica
#
# R. Koenker (2005): Quantile Regression. Cambridge.
#
# G. Carlier, V. Chernozhukov, A. Galichon (2016): 
# "Vector Quantile Regression: an optimal transport approach". Annals of Statistics.  

require('Matrix')
require('gurobi')
require('quantreg')
library(ggplot2)
t = 0.5

thePath = getwd()
# 
engeldataset = as.matrix(read.csv(paste0(thePath,"/EngelDataset.csv"),sep=",", header=TRUE)) # loads the data

n = dim(engeldataset)[1]
ncoldata = dim(engeldataset)[2]

X0 = engeldataset[,ncoldata]

Y = engeldataset[,1]


thedata = data.frame(X0,Y)

ggplot(thedata, aes(X0,Y)) + geom_point() + geom_smooth(method="lm")

QRres = rq(Y ~ X0, data=thedata, tau = t )

print(summary(QRres))

# now, let's do it ourselves
X=cbind(1,X0)
k=dim(X)[2]
obj=c(rep(t,n),rep(1-t,n),rep(0,k))
A=cbind(sparseMatrix(1:n,1:n),-sparseMatrix(1:n,1:n),X)
result	= gurobi (list(A=A,obj=obj,modelsense="min",rhs=c(Y),lb=c(rep(0,2*n),rep(-Inf,k)),sense="=")) 
thebeta = result$x[(2*n+1):(2*n+k)]

# let's now do the vector case

print(thebeta)

# now let's move to VQR

VQRTp<-function(X,Y,U,mu,nu){

  n	<-dim(Y)[1]
  d	<-dim(Y)[2]
  r	<-dim(X)[2]
  m	<-dim(U)[1]
  if ((n != dim(X)[1]) |( d != dim(U)[2] )) {stop("wrong dimensions")}
  xbar	<- t(nu)%*% X
  
  c	<- -t(matrix(U %*% t(Y),nrow=n*m))
  # c <- t(-kronecker(Y,U) %*% matrix(diag(1,d),nrow=d*d)) ### TO BE REMOVED
  A1 <- kronecker(sparseMatrix(1:n,1:n),matrix(1,1,m))
  A2 <- kronecker(t(X),sparseMatrix(1:m,1:m))
  f1 <- matrix(t(nu),nrow=n)
  f2 <- matrix(mu %*% xbar,nrow=m*r)
  e <- matrix(1,m*n,1)
  A <- rbind2(A1,A2)
  f <- rbind2(f1,f2)
  pi_init <- matrix(mu %*% t(nu),nrow=m*n)
  
  ############### LP SOLVING PHASE ###############
  result		<- gurobi (list(A=A,obj=c,modelsense="min",rhs=f,ub=e,sense="=",start=pi_init), params=NULL ) 
  if (result$status=="OPTIMAL") {pivec <- result$x; Lvec <- t(result$pi) } else {stop("optimization problem with Gurobi")}
  
  #############################################
  
  pi 		<-matrix(pivec,nrow=m)
  L1vec 	<-Lvec[1:n]
  L2vec 	<-Lvec[(n+1):(n+m*r)]
  L1		<-matrix(L1vec,1)
  L2		<-matrix(L2vec,m)
  
  psi		<- -t(L1)
  b	    <- -L2
  val		<- matrix.trace(t(U) %*% pi %*% Y)
  
  #############################################
  
  
  return(list(pi=pi,psi=psi,b=b, val=val))
}


ComputeBeta1D <- function( mu,b){
  m <-dim(mu)[1]
  D <-diag(1,m);
  for (i in 1:(m-1)) {D[i+1,i] <- (-1)}
  beta<-diag(c(1/mu))%*% D %*% b
  return(beta)
}

nu	<- matrix(1/n,n,1)
step<- 0.1
Ts	<- seq(0,1,by=step)
m	<- length(Ts)
U	<- matrix(Ts,m,1)
mu	<- matrix(1/m, m,1)
d = 1
library(matrixcalc)
sols	<- VQRTp( X,matrix(Y,n,d),U,mu,nu ) 
pi<-sols$pi; psi<-sols$psi; b<-sols$b; val<-sols$val
betasVQR		<- ComputeBeta1D( mu,b )
thebetaVQR = betasVQR[6,]