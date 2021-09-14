library(tictoc)

thepath = getwd()
tradedata = read.csv("1_TraditionalGravity_from_WTO_book.csv")   
head(tradedata)

# Unique list of importers
countrylist = sort(unique(tradedata$importer))
# Unique list of exporters
exportercountrylist = sort(unique(tradedata$exporter))
if (!identical(countrylist, exportercountrylist)) {
  stop("exporter and importer country lists do not coincide")
}

# regressorsIndices = 4:13
regressorsIndices = c("ln_DIST", "CNTG", "LANG", "CLNY")
yearslist = c(1986, 1990, 1994, 1998, 2002, 2006)

regressors_raw = tradedata[regressorsIndices]
regressorsNames = names(regressors_raw)
flow_raw = tradedata$trade

nbt = length(yearslist)  # number of years
nbk = dim(regressors_raw)[2]  # number of regressors
nbi = length(countrylist)  # number of countries
yearsIndices = 1:nbt

Dnikt = array(0, dim = c(nbi, nbi, nbk, nbt))  # basis functions
Xhatnit = array(0, dim = c(nbi, nbi, nbt))  # trade flows from n to i

missingObs = array(0, dim = c(0, 2, nbt))

for (year in 1:nbt) {
  theYear = yearslist[year]
  # print(theYear)
  for (dest in 1:nbi) {
    theDest = as.character(countrylist[dest])
    # print(theDest)
    for (orig in 1:nbi) {
      if (orig != dest) {
        theOrig = as.character(countrylist[orig])
        extract = (tradedata$exporter == theOrig) & (tradedata$importer == 
                                                       theDest) & (tradedata$year == theYear)
        line = regressors_raw[extract, ]
        
        if (dim(line)[1] == 0) {
          missingObs = rbind(missingObs, c(theOrig, theDest))
        }
        
        if (dim(line)[1] > 1) {
          stop("Several lines with year, exporter and importer.")
        }
        
        if (dim(line)[1] == 1) {
          Dnikt[orig, dest, , year] = as.numeric(line)
          Xhatnit[orig, dest, year] = flow_raw[extract]
        }                
      }
    }
  }
}
if (length(missingObs) > 0) {
  stop("Missing observations")
}
Xnt = apply(X = Xhatnit, MARGIN = c(1, 3), FUN = sum)
Yit = apply(X = Xhatnit, MARGIN = c(2, 3), FUN = sum)



sigma = 1  # sigma for IPFP
maxiterIpfp = 1000  # max numbers of iterations
tolIpfp = 1e-12  # tolerance for IPFP
tolDescent = 1e-12  # tolerance for gradient descent

totmass_t = rep(sum(Xnt)/nbt, nbt)  # total mass
p_nt = t(t(Xnt)/totmass_t)  # proportion of importer expenditure
q_nt = t(t(Yit)/totmass_t)  # proportion of exporter productions
IX = rep(1, nbi)
tIY = matrix(rep(1, nbi), nrow = 1)

f_nit = array(0, dim = c(nbi, nbi, nbt))
g_nit = array(0, dim = c(nbi, nbi, nbt))
pihat_nit = array(0, dim = c(nbi, nbi, nbt))

sdD_k = rep(1, nbk)
meanD_k = rep(0, nbk)

for (t in 1:nbt) {
  f_nit[, , t] = p_nt[, t] %*% tIY
  g_nit[, , t] = IX %*% t(q_nt[, t])
  pihat_nit[, , t] = Xhatnit[, , t]/totmass_t[t]
}

for (k in 1:nbk) {
  meanD_k[k] = mean(Dnikt[, , k, ])
  sdD_k[k] = sd(Dnikt[, , k, ])
  Dnikt[, , k, ] = (Dnikt[, , k, ] - meanD_k[k])/sdD_k[k]
}


v_it = matrix(rep(0, nbi * nbt), nbi, nbt)
beta_k = rep(0, nbk)

t_s = 0.03  # step size for the prox grad algorithm (or grad descent when lambda=0)
iterCount = 0

tic()

while (1) {
  thegrad = rep(0, nbk)
  pi_nit = array(0, dim = c(nbi, nbi, nbt))
  
  for (t in 1:nbt) {
    D_ij_k = matrix(Dnikt[, , , t], ncol = nbk)
    Phi = matrix(D_ij_k %*% matrix(beta_k, ncol = 1), nrow = nbi)
    contIpfp = TRUE
    iterIpfp = 0
    v = v_it[, t]
    f = f_nit[, , t]
    g = g_nit[, , t]
    K = exp(Phi/sigma)
    diag(K) = 0
    gK = g * K
    fK = f * K
    
    
    while (contIpfp) {
      iterIpfp = iterIpfp + 1
      u = sigma * log(apply(gK * exp((-IX %*% t(v))/sigma), 1, sum))
      vnext = sigma * log(apply(fK * exp((-u %*% tIY)/sigma), 2, sum))
      error = max(abs(apply(gK * exp((-IX %*% t(vnext) - u %*% tIY)/sigma), 
                            1, sum) - 1))
      if ((error < tolIpfp) | (iterIpfp >= maxiterIpfp)) {
        contIpfp = FALSE
      }
      v = vnext
    }
    v_it[, t] = v
    pi_nit[, , t] = f * gK * exp((-IX %*% t(v) - u %*% tIY)/sigma)
    if (iterIpfp >= maxiterIpfp) {
      stop("maximum number of iterations reached")
    }
    
    thegrad = thegrad + c(c(pi_nit[, , t] - pihat_nit[, , t]) %*% D_ij_k)
    
  }
  # take one gradient step
  beta_k = beta_k - t_s * thegrad
  
  theval = sum(thegrad * beta_k) - sigma * sum(pi_nit[pi_nit > 0] * log(pi_nit[pi_nit > 
                                                                                 0]))
  
  iterCount = iterCount + 1
  
  if (iterCount > 1 && abs(theval - theval_old) < tolDescent) {
    break
  }
  theval_old = theval
}

beta_k = beta_k/sdD_k

toc()
print(beta_k)


tic()

glm_pois = glm(as.formula(
  paste("trade ~ ", 
        paste(grep("PORTER_TIME_FE", names(tradedata), value=TRUE), collapse=" + "), 
        " + ln_DIST + CNTG + LANG + CLNY")),
  family = quasipoisson,
  data=subset(tradedata, exporter!=importer) )

toc()

glm_pois$coefficients[regressorsIndices]



#install.packages("gravity")
library(gravity)
tic()

grav_pois = ppml('trade', 'DIST', c(grep("PORTER_TIME_FE", names(tradedata), value=TRUE), 'CNTG', 'LANG', 'CLNY'),
                 vce_robust = FALSE, data = subset(tradedata, exporter!=importer))

toc()

grav_pois$coefficients[c("dist_log", "CNTG", "LANG", "CLNY"), 1]

