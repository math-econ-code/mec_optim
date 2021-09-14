#################################################
##########  (c) by Alfred Galichon     ##########
#################################################

require('Matrix')
require('gurobi')
syntheticData = T
doGurobi = T
doIPFP1 = F
doIPFP2 = T

tol=1E-9
maxiter = 1000000
sigma = 0.001 # note: 0.1 to 0.001


if (syntheticData)
{
  seed = 777
  nbX=10
  nbY=8
  set.seed(seed)
  Phi=matrix(runif(nbX*nbY),nrow=nbX)
  p=rep(1/nbX,nbX)
  q=rep(1/nbY,nbY)
} else
{
  thePath = getwd()
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
  nbX = length(p)
  nbY = length(q)
}
nrow = min(8,nbX)
ncol = min(8,nbY)

if (doGurobi)
{
A1 = kronecker(matrix(1,1,nbY),sparseMatrix(1:nbX,1:nbX))
A2 = kronecker(sparseMatrix(1:nbY,1:nbY),matrix(1,1,nbX))
A = rbind2(A1,A2)

d = c(p,q) 

ptm=proc.time()
result   = gurobi ( list(A=A,obj=c(Phi),modelsense="max",rhs=d,sense="="), params=list(OutputFlag=0) ) 
time <- proc.time()-ptm
print(paste0('Time elapsed (Gurobi) =', time[1], 's.')) 

if (result$status=="OPTIMAL") {
  pi = matrix(result$x,nrow=nbX)
  u_gurobi = result$pi[1:nbX]
  v_gurobi = result$pi[(nbX+1):(nbX+nbY)]
  val_gurobi = result$objval
} else {stop("optimization problem with Gurobi.") }

print(paste0("Value of the problem (Gurobi) = ",val_gurobi))
print(u_gurobi[1:nrow]-u_gurobi[nrow])
print(v_gurobi[1:ncol]+u_gurobi[nrow])
print("***********************")
}

############################
############################

# computation of the  regularized problem with the  IPFP

if (doIPFP1)
{
  ptm=proc.time()
  cont = TRUE
  iter = 0
  
  K=exp(Phi/sigma)
  B=rep(1,nbY)
  while (cont) {
    iter = iter+1
    A = p / c(K %*% B)
    KA = c(t(A) %*% K)
    error = max(abs(KA*B / q - 1))
    if( (error<tol) | (iter >= maxiter)) {cont=FALSE}
    B = q / KA 
  }
  u = - sigma * log(A)
  v = - sigma * log(B)
  pi = (K * A) * matrix(B,nbX,nbY, byrow = T)
  val = sum(pi*Phi) - sigma* sum(pi*log(pi))
  time = proc.time()-ptm
  
  if (iter >= maxiter ) 
  {print('Maximum number of iterations reached in IPFP1.')
  } else {
    print(paste0("IPFP1 converged in ",iter, " steps and ", time[1], "s."))
    print(paste0("Value of the problem (IPFP1) = ",val))
    print(paste0("Sum(pi*Phi) (IPFP1) = ",sum(pi*Phi)))
    print(u[1:nrow]-u[nrow])
    print(v[1:ncol]+u[nrow])
  }
  
  print("***********************")
  
}

############################
############################
if (FALSE)
{
  ptm=proc.time()
  iter = 0
  cont=TRUE
  v = rep(0,nbY)
  mu = - sigma * log(p)
  nu = - sigma * log(q)
  
  while(cont)
  {
    #print(iter)
    iter = iter+1
    u=mu + sigma * log( apply(exp( (Phi - matrix(v,nbX,nbY,byrow=T) )/sigma) ,1, sum) )
    KA = apply(exp( (Phi - u)/sigma) ,2, sum)
    error = max(abs(KA*exp(-v / sigma)/q  - 1))
    if( (error<tol) | (iter >= maxiter)) {cont=FALSE}
    
    v = nu + sigma * log(KA)
  }
  pi = exp( ( Phi - u - matrix(v,nbX,nbY,byrow=T) ) / sigma )
  val = sum(pi*Phi) - sigma* sum((pi*log(pi))[which(pi != 0)])
  time = proc.time()-ptm
  
  if (iter >= maxiter ) 
  {print('Maximum number of iterations reached in IPFP1bis.')
  } else {
    print(paste0("IPFP1bis converged in ",iter, " steps and ", time[1], "s."))
    print(paste0("Value of the problem (IPFP1bis) = ",val))
    print(paste0("Sum(pi*Phi) (IPFP1bis) = ",sum(pi*Phi)))
    print(u[1:nrow]-u[nrow])
    print(v[1:ncol]+u[nrow])
  }
  
  print("***********************")
  
}
############################
############################
if (doIPFP2)
{
  
  ptm=proc.time()
  iter = 0
  cont=TRUE
  v = rep(0,nbY)
  mu = - sigma * log(p)
  nu = - sigma * log(q)
  uprec = -Inf
  while(cont)
  {
    #print(iter)
    iter = iter+1
    vstar = apply(t(t(Phi) - v), 1, max)
    
    u=mu + vstar + sigma * log( apply(exp( (Phi - matrix(v,nbX,nbY,byrow=T) - vstar)/sigma) ,1, sum) )
    error = max(abs(u-uprec))
    uprec = u
    
    ustar = apply( Phi - u , 2, max)
    v = nu + ustar + sigma * log(apply(exp( (Phi - u - matrix(ustar,nbX,nbY,byrow=T) )/sigma) ,2, sum))
    
    if( (error<tol) | (iter >= maxiter)) {cont=FALSE}
    
  }
  pi = exp( ( Phi - u - matrix(v,nbX,nbY,byrow=T) ) / sigma )
  val = sum(pi*Phi) - sigma* sum(pi*log(pi))
  time = proc.time()-ptm
  
  if (iter >= maxiter ) 
  {print('Maximum number of iterations reached in IPFP2.')
  } else {
    print(paste0("IPFP2 converged in ",iter, " steps and ", time[1], "s."))
    print(paste0("Value of the problem (IPFP2) = ",val))
    print(paste0("Sum(pi*Phi) (IPFP2) = ",sum(pi*Phi)))
    print(u[1:nrow]-u[nrow])
    print(v[1:ncol]+u[nrow])
  }
  
}


