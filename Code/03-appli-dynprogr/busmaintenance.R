rm(list=ls())

library('Matrix')
library('gurobi')
nbX = 10 #30
nbT = 40 #40
nbY = 2 # choice set: 1=run as usual; 2=overhaul

IdX = sparseMatrix(1:nbX,1:nbX)
LX=sparseMatrix(c(nbX,1:(nbX-1)),1:nbX)
RX=sparseMatrix(1:nbX,rep(1,nbX),dims=c(nbX,nbX))
P=kronecker(c(1,0),0.75*IdX+0.25*LX)+kronecker(c(0,1),RX)

IdT = sparseMatrix(1:nbT,1:nbT)
NT = sparseMatrix(1:(nbT-1),2:nbT,dims = c(nbT,nbT))
A = kronecker(kronecker(IdT,matrix(1,nbY,1)),IdX ) - kronecker(NT,P)

overhaulCost = 8E3 
maintCost = function(x)(x*5E2)
beta = 0.9
n1_x = rep(1,nbX)

b_xt = c(n1_x,rep(0,nbX*(nbT-1)))
u_xy = c(-maintCost(1:(nbX-1)),rep(-overhaulCost,nbX+1))
u_xyt = c(kronecker(beta^(1:nbT),u_xy))


result   = gurobi ( list(A=A,obj=c(b_xt),modelsense="min",rhs=u_xyt,sense=">",lb=-Inf), params=list(OutputFlag=0) ) 



# Backward induction

U_x_t = matrix(0,nbX,nbT)
contVals = apply(X = array(u_xyt,dim=c(nbX,nbY,nbT))[,,nbT],FUN = max,MARGIN = 1) 
U_x_t[,nbT] = contVals

for (t in (nbT-1):1)
{
  
  myopic = array(u_xyt,dim=c(nbX,nbY,nbT))[,,t]
  Econtvals = matrix(P %*% contVals,nrow=nbX)
  
  contVals = apply(X = myopic + Econtvals ,FUN = max,MARGIN = 1) 
  U_x_t[,t] = contVals
  
}
U_x_t_gurobi = array(result$x,dim=c(nbX,nbT))
print(U_x_t_gurobi[,1])
print(U_x_t[,1])


