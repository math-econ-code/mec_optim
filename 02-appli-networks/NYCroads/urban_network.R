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
# https://www.latlong.net/convert-address-to-lat-long.html

library('Matrix')
library('gurobi')
library('rgdal')
library('rdist')


load('DataNYC.RData')

#Function shortest path
shortestPath = function (arcs, nodes, originNode, destinationNode)
{
  
  nbNodes = dim(nodes)[1]
  nbArcs = dim(arcs)[1]
  n = rep(0,nbNodes)
  n[c(originNode,destinationNode)]=c(-1,1)
  Nabla =  sparseMatrix(i=1:nbArcs,j=arcs[,1],dims=c(nbArcs,nbNodes),x=-1) + sparseMatrix(i=1:nbArcs,j=arcs[,2],dims=c(nbArcs,nbNodes),x=1)
  Phi <--arcs[,3]
  
  result = gurobi ( list(A=t(Nabla),obj=Phi,modelsense='max',rhs=n,sense='=',start=matrix(0,nbArcs,1)), params=NULL)
  pi = result$x
  distance = -result$objval
  
  cont = TRUE
  i = originNode
  eqpath = which(pi>0)
  rank = 0
  nodespath=c(0)
  nodespath[rank+1]=i
  while(cont)
  { 
    rank = rank+1
    leavingi = which(Nabla[,i]==-1)
    a = intersect(eqpath,leavingi)[1]
    j = which(Nabla[a,]==1)[1]
    i = j
    nodespath[rank+1]=i
    if(j==destinationNode) {cont<-FALSE}  
  }
  
  return(nodespath)
  
  plot(shpNYC)
  points(nodes[nodespath,], col="red")
}


#Excecute the function
StartGPS = matrix(c(-73.995167,40.728936),ncol=2)
FinishGPS = matrix(c(-74.090871,40.614594),ncol=2)
StartNAD83 = project(StartGPS,"+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs")
FinishNAD83 = project(FinishGPS,"+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs")
StartNode = which.min(cdist(StartNAD83,nodes,metric = "euclidean"))
FinishNode = which.min(cdist(FinishNAD83,nodes,metric = "euclidean"))
nodespath = shortestPath(arcs,nodes,StartNode,FinishNode)

#Plot the result
plot(shpNYC)
points(nodes[nodespath,], col="red")

#Function color attraction cells A REPRENDRE
colorAttractionCells = function (sinks, sinksColors, nodes, arcs, igraphNYC) {
  
  nbSinks = length(sinks)
  nbNodes = dim(nodes)[1]
  nbArcs = dim(arcs)[1]
  
  namesNodes=as.character(1:nbNodes)
  incomingFlow = matrix(rep(1/nbNodes,nbNodes), ncol = 1)
  class(incomingFlow)="numeric"
  nexit= rep(0,nbNodes)
  nexit[sinks]=  1 / nbSinks
  n = - incomingFlow + nexit
  Nabla =  sparseMatrix(i=1:nbArcs,j=arcs[,1],dims=c(nbArcs,nbNodes),x=-1) + sparseMatrix(i=1:nbArcs,j=arcs[,2],dims=c(nbArcs,nbNodes),x=1)
  Phi <- -arcs[,3]
  
  result = gurobi ( list(A=t(Nabla),obj=Phi,modelsense='max',rhs=n,sense='=',start=matrix(0,nbArcs,1)), params=NULL)
  pi = result$x
  distance = -result$objval
  eqpath = which(pi>0)
  
  labelColors=rep("SkyBlue2",nbNodes)
  labelColors[sinks]=sinksColors
  
  sizeNodes= rep(1,nbNodes)
  sizeNodes[sinks]=4
  
  nbNodesSoFar = nbSinks
  maxIter = nbNodes
  
  iter=1
  frontiers=list()
  for (s in 1:nbSinks) {frontiers[[s]]=sinks[s]}
  
  while((nbNodesSoFar<=nbNodes) & (iter<=maxIter))
  {
    for (s in 1:nbSinks)
    { 
      newfrontier = c()
      frontier = frontiers[[s]]
      for (i in frontier)
      {
        arrivingati = which(Nabla[,i]==1)
        thearcs = intersect(eqpath,arrivingati)
        for (a in thearcs) { newfrontier = c(newfrontier,which(Nabla[a,]==-1)) } 
      }
      if (!is.null(newfrontier)) {
        labelColors[newfrontier] = sinksColors[s]
        sizeNodes[newfrontier]=4
        nbNodesSoFar = nbNodesSoFar+length(newfrontier)
        frontiers[[s]]=newfrontier
      }
      
    }
    
    iter=iter+1 
  }
  
  
  labelNodes = rep(NA,nbNodes)
  labelNodes[sinks]=namesNodes[sinks]
  # plot.igraph(igraphNYC,vertex.label=labelNodes, vertex.label.cex=1,vertex.color=labelColors,vertex.size=sizeNodes, edge.arrow.size=0, layout = nodes)
  return(labelColors)
  
}


#Attraction cells
sinks=c(7,30040,60150)
sinksColors=c("gold","firebrick2","forestgreen")
labelColors = colorAttractionCells(sinks, sinksColors, nodes, arcs, igraphNYC)
plot(shpNYC)
points(nodes, col=labelColors)