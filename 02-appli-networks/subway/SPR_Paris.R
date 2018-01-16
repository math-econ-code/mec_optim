
# to install SPR:
# require(devtools)
# install_github("TraME-Project/Shortest-Path-R")

#

rm(list=ls())
library(SPR)

# load data

thePath = getwd()
arcs = as.matrix(read.csv(paste0(thePath,"/Paris/arcs.csv"),sep=";", header=FALSE)) # loads the data
namesNodes = as.matrix(read.csv(paste0(thePath,"/Paris/nodes.csv"),sep=";", header=FALSE)) # loads the data

nbNodes = max(arcs[,1])

# set source and destination nodes

originNode <- 84 #saint-germain des pres
destinationNode<- 116 #trocadero

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
