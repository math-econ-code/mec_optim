#library(devtools)
#install_github("TraME-Project/TraME-R")

library(TraME.R)
library(gurobi)

thepath = getwd()
load(paste0(thepath,"/ChooSiowData/nSinglesv4.RData"), verbose = FALSE)
load(paste0(thepath,"/ChooSiowData/nMarrv4.RData"), verbose = FALSE)
load(paste0(thepath,"/ChooSiowData/nAvailv4.RData"), verbose = FALSE)

nbCateg = 25
nbX=nbY=nbCateg

nbPlaces =  2 # 1=nonreform, 2=reform. Note: in reform states, abortion was already partially available before Roe vs Wade.
nbYears = 2 # 1=70, 2=80
muhatsxy = array(0,dim = c(nbX,nbY,nbPlaces,nbYears))
ns = array(0,dim = c(nbX,nbPlaces,nbYears))
ms = array(0,dim = c(nbY,nbPlaces,nbYears))
#
themuhat = marr70nN[[1]][1:nbCateg,1:nbCateg]
nbCouples = sum(themuhat)
muhatsxy[,,1,1] = themuhat / nbCouples
ns[,1,1] = avail70n[[1]][1:nbCateg,1] / nbCouples
ms[,1,1] = avail70n[[1]][1:nbCateg,2] / nbCouples
#
themuhat = marr70rR[[1]][1:nbCateg,1:nbCateg]
nbCouples = sum(themuhat)
muhatsxy[,,2,1] = themuhat / nbCouples
ns[,2,1] = avail70r[[1]][1:nbCateg,1] / nbCouples
ms[,2,1] = avail70r[[1]][1:nbCateg,2] / nbCouples
#
themuhat = marr80nN[[1]][1:nbCateg,1:nbCateg]
nbCouples = sum(themuhat)
muhatsxy[,,1,2] = themuhat / nbCouples
ns[,1,2] = avail80n[[1]][1:nbCateg,1] / nbCouples
ms[,1,2] = avail80n[[1]][1:nbCateg,2] / nbCouples
#
themuhat = marr80rR[[1]][1:nbCateg,1:nbCateg]
nbCouples = sum(themuhat)
muhatsxy[,,2,2] = themuhat / nbCouples
ns[,2,2] = avail80r[[1]][1:nbCateg,1] / nbCouples
ms[,2,2] = avail80r[[1]][1:nbCateg,2] / nbCouples
#

if (nbX != nbY) {stop("nbx != nbY")}
Xvals = Yvals = (15+c(1:nbX))


# building the model
# regressors:
diffs = c(outer(Xvals,Yvals,"-"))
agex = c(outer(Xvals,rep(0,nbY),"+"))
agey = c(outer(rep(0,nbX),Yvals,"+"))
posdiffs = diffs *(diffs>0)
negdiffs = - diffs *(diffs<0)
posdiffs2 = posdiffs*posdiffs
negdiffs2 = negdiffs * negdiffs
diffs2 = diffs*diffs
ones = matrix(1,nbX,nbY)
skewedDiffs0 = (diffs - 0) *(diffs - 0 > 0)
skewedDiffs1 = (diffs - 1) *(diffs - 1 > 0)
skewedDiffs2 = (diffs - 2) *(diffs - 2 > 0)
sqSkewedDiffs0 = skewedDiffs0 * skewedDiffs0
sqSkewedDiffs1 = skewedDiffs1 * skewedDiffs1
sqSkewedDiffs2 = skewedDiffs2 * skewedDiffs2

# assembling regressors
#regs = c(ones,agex,agey,agex*agex,agey*agey,agex*agey,skewedDiffs1,sqSkewedDiffs1)
regs=c(agex,agey,agex*agex,agey*agey,agex*agey,ones) 

dimTheta = length(regs) %/% (nbX*nbY)
phi_xyk = array( regs , dim = c(nbX,nbY,dimTheta))
thetahats = array(0,dim=c(dimTheta,nbPlaces,nbYears))
vals =statuses = entropies = array(0,dim=c(nbPlaces,nbYears))

thescale = 10
cupidsLogitModel=list()
for (i in 1:nbPlaces)
{
  for (j in 1:nbYears)
  {
    then = ns[,i,j]
    them = ms[,i,j]
    themodel = buildModel_TUlogit( phi_xyk /thescale  , n=then,m=them ) 
    cupidsLogitModel[[i+(j-1)*nbPlaces]] = themodel
    themuxy = muhatsxy[,,i,j]
    res = themodel$mme(themodel,themuxy)
    themkt = themodel$parametricMarket(model = themodel, res$thetahat )
#    entropy = Gstar(arums = themkt$arumsG,mu = themuxy, n =then)$val + Gstar(arums = themkt$arumsH,mu = t(themuxy),n = them )$val
    thetahats[,i,j] = res$thetahat / thescale
#   statuses[i,j] = res$status
#  vals[i,j] = res$val + entropy
#    entropies[i,j] = entropy
    
  }
}



Diff70 = thetahats[,2,1] - thetahats[,1,1] # gains reform - gains nonreform in 70
Diff80 = thetahats[,2,2] - thetahats[,1,2] # gains reform  - gains nonreform in 80
DiD = Diff70 - Diff80
cat("DiffsInDiffs (70r-70n)-(80r-80n):\n")
print(DiD)
