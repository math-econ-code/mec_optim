#################################################
##########       Alfred Galichon       ##########
#################################################

library('gurobi')
library('Matrix')

thePath = getwd()
#data = read.csv(paste0(thePath,"/distances.csv"),sep=",", header=TRUE)
data = as.matrix(read.csv(paste0(thePath,"/distances.csv"),sep=",", header=TRUE)) # loads the data
nsources = 68
ndests = 10
dists = matrix(as.numeric(data[1:68,2:11]),68,10)
p = matrix(as.numeric(data[1:68,12]))
q = matrix(as.numeric(data[69,2:11]))
nonzeros = which(! is.na(dists))

nbNodes = nsources+ndests
nbArcs = length(nonzeros)

rows = (nonzeros-1) %% nsources + 1
cols = (nonzeros-1) %/% nsources + 1 
costs = dists[nonzeros]
arcs = cbind(rows,cols+nsources,costs)

n = c(-p,q)
nameNodes = c(data[1:nsources] ,dimnames(data)[[2]][2:11])


# construct node-incidence matrix:
Nabla =  sparseMatrix(i=1:nbArcs,j=arcs[,1],dims=c(nbArcs,nbNodes),x=-1) + sparseMatrix(i=1:nbArcs,j=arcs[,2],dims=c(nbArcs,nbNodes),x=1)


# solve LP via Gurobi
result = gurobi ( list(A=t(Nabla),obj=costs,modelsense='min',rhs=n,sense='=',start=matrix(0,nbArcs,1)), params=NULL)
pi = result$x
distance = result$objval

print(distance)
