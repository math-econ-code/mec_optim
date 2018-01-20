
#install.packages("devtools")
#library(devtools)
#install_github("TraME-Project/TraME-R")

library(TraME.R)

seed=777
nbX=18
nbY=5

  set.seed(seed)
  tm = proc.time()
  #
  #
  n=rep(1,nbX)
  m=rep(1,nbY)
  
  alpha = matrix(runif(nbX*nbY),nrow=nbX)
  gamma = matrix(runif(nbX*nbY),nrow=nbX)
  lambda = matrix(1+runif(nbX*nbY),nrow=nbX)
  zeta = matrix(1+runif(nbX*nbY),nrow=nbX)
  
  
  m1 = DSEToMFE(build_market_TU_logit(n,m,alpha+gamma,neededNorm = defaultNorm(F)) ) 
  m2 = DSEToMFE(build_market_NTU_logit(n,m,alpha,gamma,neededNorm = defaultNorm(F)) )
  m3 = DSEToMFE(build_market_LTU_logit(n,m,lambda/(lambda+zeta),(lambda*alpha+zeta*gamma)/(lambda+zeta),neededNorm = defaultNorm(F)) )
  #
  r1 = ipfp(m1,xFirst=TRUE,notifications=TRUE)
  message("Solution of TU-logit problem using ipfp:")
  print(c(r1$mu))
  message("")
  #
    r2 = ipfp(m2,xFirst=TRUE,notifications=TRUE)
    message("Solution of NTU-logit problem using ipfp:")
    print(c(r2$mu))
    message("")
  
  #
  r3 = ipfp(m3,xFirst=TRUE,notifications=TRUE)
  message("Solution of LTU-logit problem using parallel ipfp:")
  print(c(r3$mu))
  #
  time <- proc.time() - tm
  message(paste0('\nEnd of test_ipfp. Time elapsed = ', round(time["elapsed"],5), 's.\n'))
  #
  
