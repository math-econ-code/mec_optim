thepath = getwd()

nSingles= read.table(paste0(thepath, "/n_singles.txt"))
marr = read.table(paste0(thepath, "/marr.txt"))
nAvail = read.table(paste0(thepath, "/n_avail.txt"))

nbCateg = 25  # keep only the 16-40 yo population

muhat_x0 = nSingles[1:nbCateg,1]
muhat_0y = nSingles[1:nbCateg,2]
muhat_xy = as.matrix(marr[1:nbCateg,1:nbCateg])

Nh = sum(muhat_xy)+sum(muhat_x0)+sum(muhat_0y)

muhat_xy = muhat_xy / Nh 
muhat_x0 = muhat_x0 / Nh 
muhat_0y = muhat_0y / Nh

n_x=apply(X=muhat_xy,MARGIN=1,FUN=sum)+muhat_x0 
m_y=apply(X=muhat_xy,MARGIN=2,FUN=sum)+muhat_0y


nbX=nbY=nbCateg
xs=matrix(rep(1:nbX,nbY),nbX,nbY)
ys=matrix(rep(1:nbY,nbX),nbX,nbY, byrow=T)
phi1_xy = - c((xs-ys)^2)
phimat = cbind( phi1_xy , phi1_xy*c( ( (xs+ys)/2 )^2), phi1_xy*c( ( (xs+ys-2)/2 )^2), phi1_xy*c( ( (xs+ys-1) )^2))
nbK = dim(phimat)[2]
phimat_mean = apply(X = phimat,MARGIN = 2,FUN = mean)
phimat_stdev = apply(X = phimat,MARGIN = 2,FUN = sd)
phimat = (phimat - matrix(phimat_mean,nbX*nbY,nbK,byrow = T)) / matrix(phimat_stdev,nbX*nbY,nbK,byrow = T)



ObjFunc=function(uvlambda)
{
  u_x = uvlambda[1:nbX]
  v_y = uvlambda[(nbX+1):(nbX+nbY)]
  lambda = uvlambda[(nbX+nbY+1):(nbX+nbY+nbK)]
  Phi_xy = matrix(phimat %*% matrix(lambda,ncol=1),nbX,nbY)
  mu_xy = exp((Phi_xy- matrix(u_x,nbX,nbY)- matrix(v_y,nbX,nbY,byrow = T) ) /2)
  mu_x0 = exp(-u_x)
  mu_0y = exp(-v_y)
  
  val = sum(n_x*u_x)+sum(m_y*v_y) - sum(muhat_xy*Phi_xy) + 2* sum(mu_xy) + sum(mu_x0) + sum(mu_0y)
  grad_u = n_x - apply(X = mu_xy,MARGIN = 1,FUN = sum) - mu_x0
  grad_v = m_y - apply(X = mu_xy,MARGIN = 2,FUN = sum) - mu_0y
  grad_lambda = c(mu_xy - muhat_xy) %*% phimat
  grad = c(grad_u,grad_v,grad_lambda)
  res = val
  attr(res, "gradient") = grad
  #print(val)
  #print(max(abs(uvlambda)))
  return(res)
}


outcome=nlm(ObjFunc,rep(0,nbX+nbY+nbK), iterlim=1000)
uvlambdahat = outcome$estimate
lambdahat = uvlambdahat[(nbX+nbY+1):(nbX+nbY+nbK)]
print(str(outcome))
print(ObjFunc(uvlambdahat))
print(lambdahat)
