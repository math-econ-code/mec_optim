# simulate a probit model
library(Matrix)
library(gurobi)
#seed = 777
#set.seed(seed)
U_y = c(0.4, 0.5, 0.2, 0.3, 0.1, 0)

nbDraws = 1E6
nbY = length(U_y)
rho = 0.5

Covar =  rho * matrix(1,nbY,nbY) + (1-rho) * diag(1,nbY)
E = eigen(Covar)
V = E$values 
Q = E$vectors
SqrtCovar = Q%*%diag(sqrt(V))%*%t(Q) 
epsilon_iy = matrix(rnorm(nbDraws*nbY),ncol=nbY) %*% SqrtCovar
#
u_iy = t(t(epsilon_iy)+U_y) 
ui = apply(X = u_iy, MARGIN  = 1, FUN = max)
s_y = apply(X = u_iy - ui, MARGIN = 2,FUN = function(v) (length(which(v==0)))) / nbDraws


A1 = kronecker(matrix(1,1,nbY),sparseMatrix(1:nbDraws,1:nbDraws))
A2 = kronecker(sparseMatrix(1:nbY,1:nbY),matrix(1,1,nbDraws))
A = rbind2(A1,A2)
result   = gurobi ( list(A=A,obj=c(epsilon_iy),modelsense="max",rhs=c(rep(1/nbDraws,nbDraws),s_y) ,sense="="), params=list(OutputFlag=0) ) 
Uhat_y = - result$pi[(1+nbDraws):(nbY+nbDraws)] + result$pi[(nbY+nbDraws)]

print("U_y (true and recovered)")
print(U_y)
print(Uhat_y)


