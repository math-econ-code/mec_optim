useGLM = FALSE
loadPastEnv= TRUE
# countrylist = sort(unique(tradedata$importer))
# exportercountrylist = sort(unique(tradedata$exporter))
# if (!identical(countrylist, exportercountrylist)) {stop("exporter and importer country lists do not coincide")}
# 
# #regressorsIndices = 4:13
# regressorsIndices = c("ln_DIST","CNTG","LANG","CLNY","ln_Y","ln_E")
# yearslist = c(1986, 1990, 1994, 1998, 2002, 2006)
# 
# regressors_raw = tradedata[regressorsIndices]
# regressorsNames = names(regressors_raw)
# flow_raw = tradedata$trade

#############################################
#### OUR APPROACH STARTS HERE ###############
#############################################

#############################################
############ DATA PREPARATION ###############
#############################################
if (TRUE)
{
  if (loadPastEnv)
  {
    load("../Data/dataFromGravityBook.RData")
  } else{
    setwd("C:/Users/Alfred/Dropbox/Collaborations/_Arnaud/YifeiArnaudAlfred/GravityEquation/Rcodes")
    dataFile = "1_TraditionalGravity_from_WTO_book.csv"
    tradedata=read.csv(dataFile)
    countrylist = sort(unique(tradedata$importer))
    exportercountrylist = sort(unique(tradedata$exporter))
    if (!identical(countrylist, exportercountrylist)) {stop("exporter and importer country lists do not coincide")}
    
    
    #regressorsIndices = 4:13
    regressorsIndices = c("ln_DIST","CNTG","LANG","CLNY")
    yearslist = c(1986, 1990, 1994, 1998, 2002, 2006)
    
    regressors_raw = tradedata[regressorsIndices]
    regressorsNames = names(regressors_raw)
    flow_raw = tradedata$trade
    
    
    
    nbt = length(yearslist) # number of years
    nbk = dim(regressors_raw)[2] # number of regressors
    nbi = length(countrylist) # number of countries
    yearsIndices = 1:nbt
    
    
    Dnikt = array(0,dim=c(nbi,nbi,nbk,nbt)) # basis functions
    Xhatnit = array(0,dim=c(nbi,nbi,nbt)) # trade flows from n to i
    
    missingObs = array(0,dim = c(0,2,nbt))
    
    for (year in 1:nbt)
    {
      theYear = yearslist[year]
      print(theYear)
      for (dest in 1:nbi)
      {
        theDest = as.character(countrylist[dest])
        print(theDest)
        for (orig in 1:nbi)
        {
          if (orig != dest )
          {
            theOrig = as.character(countrylist[orig])
            extract = (tradedata$exporter == theOrig) & (tradedata$importer == theDest) & (tradedata$year == theYear)
            line = regressors_raw[extract , ]
            
            if (dim(line)[1] == 0 )
            { missingObs = rbind(missingObs,c(theOrig,theDest)) }
            
            if (dim(line)[1] > 1 )
            { stop("Several lines with year, exporter and importer.") }
            
            if (dim(line)[1] == 1 )
            {
              Dnikt[orig,dest,,year] = as.numeric(line)
              Xhatnit[orig,dest,year] = flow_raw[extract]
            }
            
            
          }
        }
      }
    }
    
    if(length(missingObs) > 0) {stop("Missing observations")}
    Xnt = apply(X = Xhatnit,MARGIN = c(1,3),FUN = sum)
    Yit = apply(X = Xhatnit,MARGIN = c(2,3),FUN = sum)
    
  }
  
  if (useGLM)
  {
    library(multiwayvcov)
    library(lmtest)
    
    m4 = glm(as.formula(
      paste("trade ~ ", 
            paste(grep("PORTER_TIME_FE", names(tradedata), value=TRUE), collapse=" + "), 
            " + ln_DIST + CNTG + LANG + CLNY")),
      family = quasipoisson,
      data=subset(tradedata, exporter!=importer) )
    
    summary(m4)
    vcov_pairID = cluster.vcov(m4, subset(tradedata, exporter!=importer)$pair_id)
    coeftest(m4, vcov_pairID)
    
  }
  #############################################
  ########## AFFINITY ESTIMATION ##############
  #############################################
  
  sigma = 1
  maxiterIpfp =1000
  lambda = 0.0
  tolIpfp = 1E-9
  tolDescent = 1E-9
  
  #totmass_t = apply(X = Xnt, MARGIN = 2, FUN = sum)
  totmass_t = rep(sum(Xnt) / nbt,nbt)
  
  p_nt = t( t(Xnt) / totmass_t)
  q_nt = t( t(Yit) / totmass_t)
  IX=rep(1,nbi)
  tIY=matrix(rep(1,nbi),nrow=1)
  
  f_nit = array(0,dim=c(nbi,nbi,nbt))
  g_nit = array(0,dim=c(nbi,nbi,nbt))
  pihat_nit = array(0,dim=c(nbi,nbi,nbt))
  
  sdD_k = rep(1,nbk)
  meanD_k = rep(0,nbk)
  
  for (t in 1:nbt)
  {
    f_nit[,,t] = p_nt[,t] %*% tIY
    g_nit[,,t] = IX %*% t(q_nt[,t])
    pihat_nit[,,t] = Xhatnit[,,t] / totmass_t[t]
  }
  
  for (k in 1:nbk)
  {
    meanD_k[k] = mean(Dnikt[,,k,])
    sdD_k[k] = sd(Dnikt[,,k,])
    Dnikt[,,k,] = (Dnikt[,,k,] - meanD_k[k]) / sdD_k[k]
  }
  
  
  u_nt = matrix(rep(0,nbi*nbt),nbi,nbt)
  v_it = matrix(rep(0,nbi*nbt),nbi,nbt)
  # beta_kt = matrix(rep(0,nbk*nbt),nbk,nbt)
  beta_k = rep(0,nbk )
  
  t_s = .03   # step size for the prox grad algorithm (or grad descent when lambda=0)
  iterCount = 0
  
  
  
  while (1)
  {
    thegrad = rep(0,nbk )
    pi_nit  = array(0,dim=c(nbi,nbi,nbt)) 
    
    for (t in 1:nbt)
    {
      D_ij_k = matrix(Dnikt[,,,t],ncol = nbk)
      Phi = matrix( D_ij_k %*% matrix( beta_k , ncol=1) , nrow = nbi)
      contIpfp = TRUE
      iterIpfp = 0
      v = v_it[,t]
      f = f_nit[,,t]
      g = g_nit[,,t]
      K = exp(Phi / sigma)
      diag(K) = 0
      gK = g*K
      fK = f * K
      
      
      while(contIpfp)
      {
        iterIpfp = iterIpfp+1
        u = sigma*log(apply(gK * exp( ( - IX %*% t(v) ) / sigma ),1,sum))
        vnext = sigma*log(apply(fK * exp( ( - u %*% tIY ) / sigma ),2,sum))
        error = max(abs(apply(gK * exp( ( - IX %*% t(vnext) - u %*% tIY ) / sigma ),1,sum)-1))
        if( (error<tolIpfp) | (iterIpfp >= maxiterIpfp)) {contIpfp=FALSE}
        v=vnext
      }
      u_nt[,t] = u
      v_it[,t] = v
      pi_nit[,,t] = f * gK * exp( ( - IX %*% t(v) - u %*% tIY ) / sigma ) 
      if (iterIpfp >= maxiterIpfp ) {stop('maximum number of iterations reached')} 
      
      
      thegrad = thegrad + c( c(pi_nit[,,t] - pihat_nit[,,t]) %*% D_ij_k)  
      
    }
    # take one gradient step
    beta_k = beta_k - t_s*thegrad 
    
    ###########################################################################
    ###########################################################################
    # if (lambda > 0)
    # {
    #   # compute the proximal operator
    #   beta_k = pmax(beta_k - lambda/nbt*t_s, 0.0) - pmax(-beta_k - lambda/nbt*t_s, 0.0)  
    #   # eqn (6.9) of the proximal methods paper
    # } # if lambda = 0 then we are just taking one step of gradient descent
    # 
    if (lambda > 0)
    {
      theval = sum(thegrad * beta_k) - sigma * sum(pi_nit[pi_nit>0]*log(pi_nit[pi_nit>0])) + lambda/nbt * sum(abs(beta_k))
    } 
    else
    {
      theval = sum(thegrad * beta_k) - sigma * sum(pi_nit[pi_nit>0]*log(pi_nit[pi_nit>0]))
    }
    
    iterCount = iterCount + 1
    #  print(min(pi_nit))
    print(theval)
    #print(c(sum(thegrad * beta_k),sigma * sum(pi_nit[pi_nit>0]*log(pi_nit[pi_nit>0]) )))
    
    if (iterCount>1 && abs(theval - theval_old) < tolDescent) { break }
    
    theval_old = theval
    
  }
}


# beta_k = 
print(beta_k / sdD_k)


Dknit = array(0, dim=c(nbk,nbi,nbi,nbt))
for (k in 1:nbk)
{
  Dknit[k,,,]=Dnikt[,,k,]
}

nbp = nbk + 2 * nbi * nbt

Zpnit = array(0,dim=c(nbp,nbi,nbi,nbt))
Zpnit[1:nbk,,,] = Dknit
for (n_or_i in 1:nbi)
  for (t in 1:nbt)
{
  Zpnit[nbk+(t-1)*nbi + n_or_i,n_or_i, ,t] = 1
  Zpnit[nbk+ nbi*nbt + (t-1)*nbi + n_or_i,,n_or_i,t] = 1
}


Z_p_nit = matrix(Zpnit,nrow = nbp)
Xhat_nit = c(Xhatnit)

beta_p = rep(0,nbp)
beta_p[1:nbk] = beta_k

for (n_or_i in 1:nbi)
  for (t in 1:nbt)
  {
    beta_p[nbk+(t-1)*nbi + n_or_i] = -u_nt[n_or_i,t] + log(Xnt[n_or_i,t]/totmass_t[t])
    beta_p[nbk+ nbi*nbt + (t-1)*nbi + n_or_i] = -v_it[n_or_i,t] + log(Yit[n_or_i,t] / totmass_t[t])
  }




  test = exp(t(Z_p_nit) %*% beta_p ) 
  test_nit = array(test,dim=c(nbi,nbi,nbt))
  
  for (i in 1:nbi)
    for (t in 1:nbt)
    {
      test_nit[i,i,t]=0
    }


  

  
    
    ps_toremove = c()
  for (t in 1:nbt)
  {
    ps_toremove = c(ps_toremove, nbk + nbi*nbt + t * nbi )
  }
    
  Zpnit = Zpnit[-ps_toremove,,,]
    
  
  hessLogLik = matrix(0,nbp-nbt,nbp-nbt)
  covScore = matrix(0,nbp-nbt,nbp-nbt)
  
    for (n in 1:nbi)
      for (i in 1:nbi)
    for (t in 1:nbt)
    {
      update = Zpnit[,n,i,t] %*% t(Zpnit[,n,i,t])
      diffs = (pi_nit[n,i,t] - pihat_nit[n,i,t])
      hessLogLik = hessLogLik + pi_nit[n,i,t] * update
      covScore = covScore +  diffs*diffs* update
          }
    
  

 invHessLogLik =  solve(hessLogLik)

  VarEstimator = invHessLogLik %*% covScore  %*% invHessLogLik

  varBeta = VarEstimator[1:nbk,1:nbk]



  print(sqrt(diag(varBeta)) / sdD_k)

  print(sqrt(nbt)* sqrt(diag(varBeta)) / sdD_k)
