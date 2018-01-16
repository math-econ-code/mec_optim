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

rm(list=ls())

library('Matrix')
# library('gurobi')
library(SPR)
library('rgdal')
library('rdist')


load('DataNYC.RData')

#Function shortest path
shortestPath = function (arcs, nodes, originNode, destinationNode)
{
    nbNodes = dim(nodes)[1]
    # nbArcs = dim(arcs)[1]
    
    sol <- dijkstra(nbNodes,originNode,arcs,destinationNode)
    
    return(sol$path_list)
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
