library(nloptr)
library(nleqslv)
library(microbenchmark)
library(Matrix)
library(gurobi)

thepath = getwd()
load(paste0(thepath,"/ChooSiowData/nSinglesv4.RData"), verbose = FALSE)
load(paste0(thepath,"/ChooSiowData/nMarrv4.RData"), verbose = FALSE)
load(paste0(thepath,"/ChooSiowData/nAvailv4.RData"), verbose = FALSE)

nbCateg = 25 # keep only the 16-40 yo population
nSingles = nSingles70n
marr = marr70nN
nAvail = avail70n

muhatx0 = nSingles[1:nbCateg,1]
muhat0y = nSingles[1:nbCateg,2]
muhatxy = marr[[1]][1:nbCateg,1:nbCateg]
then = c(nAvail[[1]][1:nbCateg,1])
them = c(nAvail[[1]][1:nbCateg,2])
nbIndiv = sum(then)+sum(them)
then = then / nbIndiv
them = them / nbIndiv

nbX = length(then)
nbY = length(them)

Xs = (1:nbCateg)+15
Ys = (1:nbCateg)+15

thephi =   - abs (matrix(Xs,nbX,nbY) - matrix(Ys,nbX,nbY,byrow=T)) /20


edgeGradient = function(Phi,n,m, xtol_rel = 1e-8 ,ftol_rel=1e-15)
{
  nbX = length(n)
  nbY = length(m)
  eval_f <- function(theU)
  {
    theU = matrix(theU,nbX,nbY)
    theV = Phi-theU
    denomG = 1 + apply(exp(theU),1,sum)
    denomH = 1 + apply(exp(theV),2,sum)
    valG = sum(n * log(denomG))
    valH = sum(m * log(denomH))
    gradG = exp( theU ) * (n / denomG)
    gradH =  t( t(exp(theV)) * (m / denomH) ) 
    #
    ret = list(objective = valG + valH,
               gradient = c(gradG - gradH ))
    #
    return(ret)
  }
  U_init = Phi / 2
  
  resopt = nloptr(x0 = U_init, eval_f = eval_f,
                  opt = list("algorithm" = "NLOPT_LD_LBFGS",
                             "xtol_rel"= xtol_rel,
                             "ftol_rel"= ftol_rel))
  Usol = matrix(resopt$solution,nbX,nbY)
  mu = exp( Usol ) * (n / (1 + apply(exp(Usol),1,sum)))
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  val = sum(mu * Phi) - 2*sum(mu*log(mu / sqrt(matrix(n,ncol=1) %*% matrix(m,nrow=1)))) - sum(mux0*log(mux0 / n)) - sum(mu0y*log(mu0y / m))
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = resopt$iterations))
}


edgeNewton = function(Phi,n,m, xtol = 1e-5 )
{
  nbX = length(n)
  nbY = length(m)
  Z <- function(theU)
  {
    theU = matrix(theU,nbX,nbY)
    theV = Phi-theU
    denomG = 1 + apply(exp(theU),1,sum)
    denomH = 1 + apply(exp(theV),2,sum)
    gradG <<- exp( theU ) * (n / denomG)
    gradH <<- t( t(exp(theV)) * (m / denomH) ) 
    #
    return(c(gradG - gradH ))
  }
  JZ <- function(theU)
  {
    hessG = hessH = matrix(0,nbX*nbY,nbX*nbY)
    #
    for(x in 1:nbX){
      for(y in 1:nbY){
        for(yprime in 1:nbY){
          
            hessG[x+nbX*(y-1),x+nbX*(yprime-1)] = ifelse(y==yprime,
                                                                 gradG[x,y]*(1-gradG[x,y]/n[x]),
                                                                 -gradG[x,y]*gradG[x,yprime]/(n[x]))
            hessH[(x-1)*nbY+y,(x-1)*nbY+yprime] = ifelse(y==yprime,
                                                                 gradH[x,y]*(1-gradH[x,y]/n[x]),
                                                                 -gradH[x,y]*gradH[x,yprime]/(n[x]))
          
        }
      }
    }
    return(hessG+hessH)
  }
  
  U_init = Phi / 2
  
  sol = nleqslv(x = U_init,
                fn = Z, jac = JZ,
                method = "Broyden", # "Newton"
                control = list(xtol=xtol))
                
  
  Usol = matrix(sol$x,nbX,nbY)
  mu = exp( Usol ) * (n / (1 + apply(exp(Usol),1,sum)))
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  val = sum(mu * Phi) - 2*sum(mu*log(mu / sqrt(matrix(n,ncol=1) %*% matrix(m,nrow=1)))) - sum(mux0*log(mux0 / n)) - sum(mu0y*log(mu0y / m))
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = sol$iter))
}


simulatedLinprogr = function (Phi,n,m,nbDraws=1e3,seed=777)
{
  nbX = length (n)
  nbY = length (m)
  nbI = nbX * nbDraws
  nbJ = nbY * nbDraws
  #
  epsilon_iy = matrix(digamma(1) - log(-log(runif(nbI*nbY))),nbI,nbY)
  epsilon0_i = c(digamma(1) - log(-log(runif(nbI))))
  
  I_ix = matrix(0,nbI,nbX)
  for (x in 1:nbX)
  {
    I_ix[(nbDraws*(x-1)+1):(nbDraws*x),x] = 1
  }
  
  eta_xj = matrix(digamma(1) - log(-log(runif(nbX*nbJ))),nbX,nbJ)
  eta0_j = c(digamma(1) - log(-log(runif(nbI))))  
  
  I_yj = matrix(0,nbY,nbJ)
  for (y in 1:nbY)
  {
    I_yj[y,(nbDraws*(y-1)+1):(nbDraws*y)] = 1
  }
  
    
  ni = c(I_ix %*% n)/nbDraws
  mj = c(m %*% I_yj)/nbDraws
  #
  # based on this, can compute aggregated equilibrium in LP 
  #
  A_11 = suppressMessages( Matrix::kronecker(matrix(1,nbY,1),sparseMatrix(1:nbI,1:nbI,x=1)) )
  A_12 = sparseMatrix(i=NULL,j=NULL,dims=c(nbI*nbY,nbJ),x=0)
  A_13 = suppressMessages( Matrix::kronecker(sparseMatrix(1:nbY,1:nbY,x=-1),I_ix) )
  
  A_21 = sparseMatrix(i=NULL,j=NULL,dims=c(nbX*nbJ,nbI),x=0)
  A_22 = suppressMessages( Matrix::kronecker(sparseMatrix(1:nbJ,1:nbJ,x=1),matrix(1,nbX,1)) )
  A_23 = suppressMessages( Matrix::kronecker(t(I_yj),sparseMatrix(1:nbX,1:nbX,x=1)) )
  
  A_1  = cbind(A_11,A_12,A_13)
  A_2  = cbind(A_21,A_22,A_23)
  
  A    = rbind(A_1,A_2)
  # 
  nbconstr = dim(A)[1]
  nbvar = dim(A)[2]
  #
  lb  = c(epsilon0_i,t(eta0_j), rep(-Inf,nbX*nbY))
  rhs = c(epsilon_iy, eta_xj+Phi %*% I_yj)
  obj = c(ni,mj,rep(0,nbX*nbY))
  sense = rep(">=",nbconstr)
  modelsense = "min"
  #
  result = gurobi(list(obj=obj,A=A,modelsense=modelsense,rhs=rhs,sense=sense,lb=lb),params=list(OutputFlag=0))
  #
  muiy = matrix(result$pi[1:(nbI*nbY)],nrow=nbI)
  mu = t(I_ix) %*% muiy
  val = sum(ni*result$x[1:nbI]) + sum(mj*result$x[(nbI+1):(nbI+nbJ)])
  
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = NA))
  
  
}

nodalGradient = function(Phi,n,m, xtol_rel = 1e-8 ,ftol_rel=1e-15)
{
  K = exp(Phi / 2)
  tK = t(K)
  nbX = length(n)
  nbY = length(m)
  eval_f=function(ab)
  {
    a = ab[1:nbX]
    b = ab[(1+nbX):(nbX+nbY)]
    A = exp(-a / 2)
    B = exp(-b / 2)
    A2 = A * A
    B2 = B * B
    val = sum(n*a)+sum(m*b) + 2 * matrix(A,nrow=1) %*% K %*% B + sum(A2) + sum(B2)
    grada = n - A * (K %*% B) - A2
    gradb = m - B * (tK %*% A) - B2
    grad = c(grada,gradb)
    return(list(objective = val, 
                gradient = grad))
  }
  ab_init = -c(log(n /2),log(m/2))
  
  resopt = nloptr(x0 = ab_init, eval_f = eval_f,
                  opt = list("algorithm" = "NLOPT_LD_LBFGS",
                             "xtol_rel"= xtol_rel,
                             "ftol_rel"= ftol_rel))
  absol = resopt$solution
  a = absol[1:nbX]
  b = absol[(1+nbX):(nbX+nbY)]
  A = exp(-a / 2)
  B = exp(-b / 2)
  mu = c(A) * t( c(B) * tK  )
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  val = sum(mu * Phi) - 2*sum(mu*log(mu / sqrt(matrix(n,ncol=1) %*% matrix(m,nrow=1)))) - sum(mux0*log(mux0 / n)) - sum(mu0y*log(mu0y / m))
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = resopt$iterations))
}

nodalNewton = function(Phi,n,m, xtol = 1e-8 )
{
  K = exp(Phi / 2)
  tK = t(K)
  nbX = length(n)
  nbY = length(m)
  Z=function(ab)
  {
    a = ab[1:nbX]
    b = ab[(1+nbX):(nbX+nbY)]
    A <<- exp(-a / 2)
    B <<- exp(-b / 2)
    A2 <<- A * A
    B2 <<- B * B
    sumx <<- A * (K %*% B)
    sumy <<- B * (tK %*% A)
    grada = n - sumx - A2
    gradb = m - sumy - B2
    grad = c(grada,gradb)
    return( grad)
  }
  JZ = function(ab)
  {
    J11 = diag(c(.5*sumx+A2))
    J22 = diag(c(.5*sumy+B2))
    J12 = .5 * c(A) * t( c(B) * tK  ) 
    J21 = t(J12)
    J = rbind(cbind(J11,J12),cbind(J21,J22))
    return(J)
  }
  
  ab_init = -c(log(n /2),log(m/2))

  sol = nleqslv(x = ab_init,
                fn = Z, jac = JZ,
                method = "Broyden", # "Newton"
                control = list(xtol=xtol))
  
  absol = sol$x
  a = absol[1:nbX]
  b = absol[(1+nbX):(nbX+nbY)]
  A = exp(-a / 2)
  B = exp(-b / 2)
  mu = c(A) * t( c(B) * tK  )
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  val = sum(mu * Phi) - 2*sum(mu*log(mu / sqrt(matrix(n,ncol=1) %*% matrix(m,nrow=1)))) - sum(mux0*log(mux0 / n)) - sum(mu0y*log(mu0y / m))
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = sol$iter))
}

ipfp = function(Phi,n,m, tol = 1e-6)
{
  K = exp(Phi / 2)
  tK = t(K)
  B  = sqrt(m)
  cont = T
  iter=0
  while (cont)
  {
    iter = iter + 1
    KBover2 = K %*% B /2
    A = sqrt(n + KBover2 * KBover2) - KBover2
    tKAover2 = tK %*% A / 2
    B = sqrt(m + tKAover2 * tKAover2) - tKAover2
    
    discrepancy = max(abs( A * ( K %*% B + A) - n ) / n)
    if (discrepancy<tol)
    {cont = F}
  }
  mu = c(A) * t( c(B) * tK  )
  mux0 = n - apply(mu,1,sum)
  mu0y = m - apply(mu,2,sum)
  val = sum(mu * Phi) - 2*sum(mu*log(mu / sqrt(matrix(n,ncol=1) %*% matrix(m,nrow=1)))) - sum(mux0*log(mux0 / n)) - sum(mu0y*log(mu0y / m))
  return(list(mu = mu, mux0 = mux0, mu0y = mu0y, val = val, iter = iter))
}


printStats = function(n,m,mu,phi,lambda)
{
  avgAbsDiff = -sum(mu * phi) / sum(mu) # average absolute age difference between matched partners
  fractionMarried = 2 * sum(mu) / (sum(n)+sum(m)) # fraction of married individuals
  # print(paste0("Value of lambda= ",lambda))
  print(paste0("Average absolute age difference between matched partners= ",avgAbsDiff))
  print(paste0("Fraction of married individuals= ",fractionMarried))
}

thelambda = 1
res_edgeGradient = edgeGradient(thelambda*thephi,then,them)
res_edgeNewton = edgeNewton(thelambda*thephi,then,them)
res_nodalGradient = nodalGradient(thelambda*thephi,then,them)
res_nodalNewton = nodalNewton(thelambda*thephi,then,them)
res_ipfp = ipfp(thelambda*thephi,then,them)
res_simulatedLinprogr = simulatedLinprogr(thelambda*thephi,then,them)


printStats(then,them,res_ipfp$mu,thephi,thelambda)

print("Values returned")
print(paste0("Edge gradient  = ",res_edgeGradient$val))
print(paste0("Edge Newton    = ",res_edgeNewton$val))
print(paste0("Nodal gradient = ",res_nodalGradient$val))
print(paste0("Nodal Newton   = ",res_nodalNewton$val))
print(paste0("IPFP           = ",res_ipfp$val))
print(paste0("Linear progr   = ",res_simulatedLinprogr$val))

#microbenchmark(edgeGradient(thelambda*thephi,then,them),edgeNewton(thelambda*thephi,then,them),nodalGradient(thelambda*thephi,then,them),nodalNewton(thelambda*thephi,then,them),ipfp(thelambda*thephi,then,them),times=10)

print("Number of iterations")
print(paste0("Edge gradient  = ",res_edgeGradient$iter))
print(paste0("Edge Newton    = ",res_edgeNewton$iter))
print(paste0("Nodal gradient = ",res_nodalGradient$iter))
print(paste0("Nodal Newton   = ",res_nodalNewton$iter))
print(paste0("IPFP           = ",res_ipfp$iter))
