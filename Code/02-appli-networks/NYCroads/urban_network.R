# Shortest path problem in the NYC road subway
#
# Reference: 
# Charpentier, A., Galichon, A., Vernet, L. (2017).  
# "Equilibrium for spatial allocation problems on networks"
#
# This code was written by Lucas Vernet  
#
#
#
# to get coordinates associated with an address:
# https://www.gps-coordinates.net/

rm(list = ls())

library("Matrix")
library("gurobi")
library("rgdal")
library("rdist")

startlat = 40.70102
startlong = -73.90414
finishlat = 40.7290094
finishlong = -73.9952367

load("DataNYC.RData")

# Function shortest path
shortestPath = function(arcs, nodes, originNode, destinationNode) {
  
  nbNodes = dim(nodes)[1]
  nbArcs = dim(arcs)[1]
  n = rep(0, nbNodes)
  n[c(originNode, destinationNode)] = c(-1, 1)
  Nabla = sparseMatrix(i = 1:nbArcs, j = arcs[, 1], dims = c(nbArcs, nbNodes), x = -1) + sparseMatrix(i = 1:nbArcs, j = arcs[, 
                                                                                                                             2], dims = c(nbArcs, nbNodes), x = 1)
  Phi <- -arcs[, 3]
  
  result = gurobi(list(A = t(Nabla), obj = Phi, modelsense = "max", rhs = n, sense = "=", start = matrix(0, nbArcs, 1)), 
                  params = NULL)
  pi = result$x
  distance = -result$objval
  
  cont = TRUE
  i = originNode
  eqpath = which(pi > 0)
  rank = 0
  nodespath = c(0)
  nodespath[rank + 1] = i
  while (cont) {
    rank = rank + 1
    leavingi = which(Nabla[, i] == -1)
    a = intersect(eqpath, leavingi)[1]
    j = which(Nabla[a, ] == 1)[1]
    i = j
    nodespath[rank + 1] = i
    if (j == destinationNode) {
      cont <- FALSE
    }
  }
  
  return(nodespath)
  
  plot(shpNYC)
  points(nodes[nodespath, ], col = "red")
}


# Excecute the function
StartGPS = matrix(c(startlong, startlat), ncol = 2)
FinishGPS = matrix(c(finishlong, finishlat), ncol = 2)
StartNAD83 = project(StartGPS, "+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs")
FinishNAD83 = project(FinishGPS, "+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs")
StartNode = which.min(cdist(StartNAD83, nodes, metric = "euclidean"))
FinishNode = which.min(cdist(FinishNAD83, nodes, metric = "euclidean"))
nodespath = shortestPath(arcs, nodes, StartNode, FinishNode)

# Plot the result
plot(shpNYC)
points(nodes[nodespath, ], col = "red")
