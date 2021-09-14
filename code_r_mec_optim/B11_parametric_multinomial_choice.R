#
thePath = getwd()
# 
library(Matrix)
library(numDeriv)
library(gurobi)
#
travelmodedataset = as.matrix(read.csv(paste0(thePath,"/../data_mec_optim/demand_travelmode/travelmodedata.csv"),sep=",", header=TRUE)) # loads the data

convertmode = Vectorize ( 
  function(inputtxt) { 
    if (inputtxt == "air") {
      return(1) 
    }
    if (inputtxt == "train") {
      return(2)
    }
    if (inputtxt == "bus") {
      return(3)
    }
    if (inputtxt == "car") {
      return(4)
    }
  }
)

convertchoice = function(x) (ifelse(x=="no",0,1))

travelmodedataset[,2] = convertmode(travelmodedataset[,2])
travelmodedataset[,3] = convertchoice(travelmodedataset[,3])
nobs = dim(travelmodedataset)[1]
nchoices = 4
ninds = nobs / nchoices
ncols =  dim(travelmodedataset)[2]
travelmodedataset = array(as.numeric(travelmodedataset),dim = c(4,ninds,ncols))
muhat_i_y = t(travelmodedataset[,,3])
muhat_iy = c(muhat_i_y)



Phi_iy_k=cbind( kronecker(sparseMatrix(i = c(2,3,4),j=c(1,2,3)),matrix(1,ninds,1) ), # fixed effect with normalization U_1 = 0
              - c(t(travelmodedataset[,,6])), # time
              - c(t(travelmodedataset[,,6]*c(travelmodedataset[,,8]))), # time*incime
              - c(t(travelmodedataset[,,7]) ) # cost
)


nbK = dim(Phi_iy_k)[2]

mean_k = apply(Phi_iy_k,FUN = mean , MARGIN =  2)
std_k = apply(Phi_iy_k,FUN = sd , MARGIN =  2)

Phi_iy_k = (Phi_iy_k - matrix(mean_k,nobs,nbK, byrow = T)) / matrix(std_k,nobs,nbK, byrow = T)


theta0 = rep(0,nbK)
sigma = 1
logLikelihood = function (theta ) {
  nbk = length(theta)
  Xtheta = Phi_iy_k %*% theta / sigma
  Xthetamat_iy= matrix(Xtheta,ninds,nchoices)
  max_i = apply(X=Xthetamat_iy,FUN = max,MARGIN = 1)
  expPhi_iy = exp(Xthetamat_iy - matrix(max_i,ninds,nchoices))
  d_i = apply(X=expPhi_iy , FUN=sum,MARGIN = 1 )
  n_i_k = apply(X= array (Phi_iy_k*c(expPhi_iy),dim = c(ninds,nchoices,nbK) ), FUN=sum,MARGIN = c(1,3) )
  thegrad = c(as.matrix(matrix(muhat_iy,1,nchoices*ninds) %*% Phi_iy_k))- apply( X = n_i_k / d_i, FUN = sum, MARGIN=2)
  res= sum(Xtheta*muhat_iy)  - sum(max_i) - sigma * sum(log(d_i ))
  
  thegrad  = - thegrad
  res = - res
  
  # num_yi = matrix(exp(Xtheta),nchoices,ninds)
  # choicepred = num_yi / matrix( apply(X=num_yi,FUN=sum,MARGIN = c(2)), nchoices, ninds, byrow=TRUE)
  # thegradbis = c(as.matrix(matrix(muhat_yi - choicepred,1,nchoices*ninds) %*% Phi_yi_k))
  # valbis = sum(c(muhat_yi)*Xtheta) - sum(log(apply(X=num_yi,FUN=sum,MARGIN = c(2))))
  # res = valbis
  
  attr(res,'gradient') = thegrad
  return(res)
}

# thefun = function (t) (c(logLikelihood(t)))
# thegrad = function (t) (attr(logLikelihood(t),'gradient'))
# grad(thefun,theta0)
# thegrad(theta0)


outcome_mle = nlm(f = logLikelihood, p = theta0 , gradtol=1E-8)
temp_mle = 1 / outcome_mle$estimate[1]
theta_mle = outcome_mle$estimate[-1] * temp_mle



obj = c(c(as.matrix(matrix(muhat_iy,1,nchoices*ninds) %*% Phi_iy_k)),-rep(1,ninds))
lengthobj = length(obj)
cstMat = cbind( -Phi_iy_k, kronecker(matrix(1,nchoices,1),sparseMatrix(i = 1:ninds , j = 1:ninds,x = 1 ))  )
cstMat = rbind(cstMat,c(1,rep(0,lengthobj-1)))
nbCstr = dim(cstMat)[1]
result = gurobi(list(A = cstMat, obj = obj, modelsense = "max", rhs = c(rep(0,nbCstr-1),1), sense =  c(rep(">",nbCstr-1),"="),lb=-Inf), params = list(OutputFlag = 0))

theta_lp = result$x[1:nbK]

indMax=100
tempMax=temp_mle
outcomemat = matrix(0,indMax+1,nbK-1)
for (k in 2:(indMax+1))
{
  thetemp = tempMax * (k-1)/indMax
  logLikelihoodFixedTemp = function(subsetoftheta )
  {
    theres = logLikelihood(c(1/thetemp,subsetoftheta))
    attr(theres,'gradient') = attr(theres,'gradient')[-1]
    #print(c(theres))
    return(theres)
  }
  outcomeFixedTemp = nlm(f = logLikelihoodFixedTemp, p = theta0[-1] , gradtol=1E-8)
  outcomemat[k,] = outcomeFixedTemp$estimate * thetemp
}
outcomemat[1,] = theta_lp[-1]

print('The zero-temperature estimator is:')
print(outcomemat[1,])

print('The mle estimator is:')
print(outcomemat[indMax+1,])

#print('The intermediate estimators are')
#print(outcomemat)
nbB=100
thetemp = 1
#epsilon_biy = array(0, dim=c(nbB,nchoices,ninds))
epsilon_biy =  array(digamma(1) - log(-log(runif(nbB*ninds*nchoices))), dim=c(nbB,ninds,nchoices))
#Phi_biy_k = kronecker(Phi_iy_k,matrix(1,nbB,1)) + kronecker(c(epsilon_biy),matrix(1,1,nbK))
muhat_biy = rep(muhat_i_y,each=nbB)
newobj = c(c(as.matrix(matrix(muhat_iy,1,nchoices*ninds) %*% Phi_iy_k)),-rep(1,ninds*nbB)/nbB  )
newlengthobj = length(newobj)
cstr1 = kronecker(-Phi_iy_k,matrix(1,nbB,1))
newcstMat = cbind( kronecker(-Phi_iy_k,matrix(1,nbB,1)) , kronecker(matrix(1,nchoices,1),sparseMatrix(i = 1:(ninds*nbB) , j = 1:(ninds*nbB),x = 1 ))  )
newnbCstr = dim(newcstMat)[1]
newresult = gurobi(list(A = newcstMat, obj = newobj, modelsense = "max", rhs = c(epsilon_biy), sense =  ">",lb=-Inf), params = list(OutputFlag = 0))

newtheta_lp = newresult$x[1:nbK] / newresult$x[1] 

print('The lp-simulated estimator is:')
print(newtheta_lp[-1])



# logLikelihoodFixedTemp = function(subsetoftheta )
# {
#   theres = logLikelihood(c(1/thetemp,subsetoftheta))
#   attr(theres,'gradient') = attr(theres,'gradient')[-1]
#   #print(c(theres))
#   return(theres)
# }

#print(rbind(newtheta_lp,theta_lp) )

#save.image()