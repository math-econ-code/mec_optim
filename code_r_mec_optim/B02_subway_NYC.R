library('gurobi')
require('Matrix')
require('igraph')

plotCurrentNetwork = function (network, curNode, nbNodes)
{sizeNodes= rep(1,nbNodes)
sizeNodes[originNode]=4
sizeNodes[destinationNode]=4
sizeNodes[curNode]=4
labelNodes = rep(NA,nbNodes)
labelNodes[originNode]=namesNodes[originNode]
labelNodes[destinationNode]=namesNodes[destinationNode]
labelNodes[curNode]=namesNodes[curNode]
plot.igraph(network,vertex.label=labelNodes, vertex.label.cex=1,vertex.size=sizeNodes, edge.arrow.size=0, layout = geoCoordinates)
}

originNode <- 84 #saint-germain des pres
destinationNode<- 116 #trocadero


thePath = paste0(getwd(),"/../data_mec_optim/networks_subway/NYC")
arcs = as.matrix(read.csv(paste0(thePath,"/arcs.csv"),sep=",", header=TRUE)) # loads the data
nodes = as.matrix(read.csv(paste0(thePath,"/nodes.csv"),sep=",", header=TRUE)) # loads the data

class(arcs) <- "numeric"

namesNodes=nodes[,1]
routeNodes = nodes[,7]

incomingFlow = nodes[,2]
class(incomingFlow)="numeric"
incomingFlow = incomingFlow / sum(incomingFlow)

originNode <- 452 #Union Sq
destinationNode<- 471  #59 St




speed=2

geoCoordinates = nodes[,3:4]
class(geoCoordinates)="numeric"

nbNodes = max(arcs[,1])
nbArcs = dim(arcs)[1]

n = rep(0,nbNodes) # construct vector of exiting flow
n[c(originNode,destinationNode)]=c(-1,1)

# construct node-incidence matrix:
Nabla =  sparseMatrix(i=1:nbArcs,j=arcs[,1],dims=c(nbArcs,nbNodes),x=-1) + sparseMatrix(i=1:nbArcs,j=arcs[,2],dims=c(nbArcs,nbNodes),x=1)

Phi <- -arcs[,4] # construct (minus) distance matrix

# solve LP via Gurobi
result = gurobi ( list(A=t(Nabla),obj=Phi,modelsense='max',rhs=n,sense='=',start=matrix(0,nbArcs,1)), params=NULL)

pi = result$x
distance = -result$objval

newyork=graph_from_edgelist(arcs[,1:2])

# deduce minimal distance path:
cont = TRUE
i = originNode
writeLines(paste0(namesNodes[i]," (#", i,")"))
eqpath = which(pi>0)
rank = 0
while(cont)
{ 
  plotCurrentNetwork(newyork,i, nbNodes)
  Sys.sleep(1/speed)
  rank = rank+1
  leavingi = which(Nabla[,i]==-1)
  a = intersect(eqpath,leavingi)[1]
  j = which(Nabla[a,]==1)[1]
  writeLines(paste0(rank,": ", namesNodes[j], " ",routeNodes[j], " (#", j,")"))
  i = j
  if(j==destinationNode) {cont<-FALSE}  
}

plotCurrentNetwork(newyork,destinationNode, nbNodes)

##################################### USING SPR
# to install SPR:
# require(devtools)
# install_github("TraME-Project/Shortest-Path-R")

#

library(SPR)

# run solver

sol <- dijkstra(nbNodes,originNode,arcs,destinationNode)
sp <- sol$path_list

# print

for (kk in 1) {
  cat("Minimum distance from ", namesNodes[originNode], " to ", namesNodes[destinationNode],":\n",sep="")
  cat(sol$min_dist,"\n\n")
  
  cat("Path:\n",sep="")
  for (i in 1:length(sp)) {
    cat(i-1,": ", namesNodes[sp[i]]," (#",sp[i],")\n",sep="")
  }
}
