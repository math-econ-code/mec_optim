#################################################
###  Optimal Transport Methods in  Economics  ###
#################################################
##########       Alfred Galichon       ##########
#################################################
##########  Princeton University Press ##########
#################################################
#
#
#################################################
###           PE 8.1: Shortest path           ###
###           via linear programming          ###
#################################################

rm(list=ls())

library("gurobi")
library("Matrix")
library("magick")
city = "NYC"  # 'Paris'

thePath = getwd()
arcs = as.matrix(read.csv(paste0(thePath, "/", city, "/arcs.csv"), sep = ",", header = TRUE))  # loads the arc data
nodes = as.matrix(read.csv(paste0(thePath, "/", city, "/nodes.csv"), sep = ",", header = TRUE))  # loads the nodes data
head(arcs)


originNode = 383  # Union Sq. on the L train
destinationNode = 394  # Myrtle Wyckoff on the L train

nbNodes = max(as.numeric(arcs[, 1]))
nbArcs = dim(arcs)[1]
namesNodes = nodes[, 1]
c = arcs[, 3]
n = rep(0, nbNodes)  # construct vector of exiting flow, net demand is zero
n[c(originNode, destinationNode)] = c(-1, 1)  # except for our origin and destination

# construct node-incidence matrix:
Nabla = sparseMatrix(i = 1:nbArcs, j = as.numeric(arcs[, 1]), dims = c(nbArcs, nbNodes), x = -1) + sparseMatrix(i = 1:nbArcs, 
                                                                                                                j = as.numeric(arcs[, 2]), dims = c(nbArcs, nbNodes), x = 1)

result = gurobi(list(A = t(Nabla), obj = as.numeric(c), sense = "=", rhs = n, modelsense = "min", start = matrix(0, nbArcs, 
                                                                                                                 1)), params = NULL)
pi = result$x
distance = result$objval


# Some plotting stuff
themargin = -c(1, 1, 0.5, 0.2)
require("igraph")
geoCoordinates = nodes[, 3:4]
class(geoCoordinates) = "numeric"
# mapCoordinates = nodes[,5:6] class(mapCoordinates)='numeric'
nbNodes = max(arcs[, 1])
nbArcs = dim(arcs)[1]

plotCurrentNetwork = function(network, curNode) {
  sizeNodes = rep(1, nbNodes)
  sizeNodes[originNode] = 4
  sizeNodes[destinationNode] = 4
  sizeNodes[curNode] = 4
  labelNodes = rep(NA, nbNodes)
  labelNodes[originNode] = namesNodes[originNode]
  labelNodes[destinationNode] = namesNodes[destinationNode]
  labelNodes[curNode] = namesNodes[curNode]
  plot.igraph(network, vertex.label = labelNodes, vertex.label.cex = 1, vertex.size = sizeNodes, edge.arrow.size = 0, layout = geoCoordinates, 
              margin = themargin)
}

thegraph = graph_from_edgelist(arcs[, 1:2])

labelColors = rep("SkyBlue2", nbNodes)
labelColors[originNode] = "firebrick2"
labelColors[destinationNode] = "forestgreen"

sizeNodes = rep(1, nbNodes)
sizeNodes[originNode] = 4
sizeNodes[destinationNode] = 4

nbNodesSoFar = 1
curpoint = originNode

cont = TRUE
i = originNode
writeLines(paste0(namesNodes[i], " (#", i, ")"))
eqpath = which(pi > 0)
rank = 0

frames = image_graph(width = 600, height = 600, res = 150)

cont = TRUE
i = originNode
writeLines(paste0(namesNodes[i], " (#", i, ")"))
eqpath = which(pi > 0)
rank = 0
while (cont) {
  rank = rank + 1
  leavingi = which(Nabla[, i] == -1)
  a = intersect(eqpath, leavingi)[1]
  j = which(Nabla[a, ] == 1)[1]
  plotCurrentNetwork(thegraph, j)
  writeLines(paste0(rank, ": ", namesNodes[j], " (#", j, ")"))
  i = j
  if (j == destinationNode) {
    cont <- FALSE
  }
}
# done with plotting
dev.off()

# animate
image_animate(frames, 1)
