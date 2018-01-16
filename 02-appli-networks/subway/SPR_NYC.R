
# to install SPR:
# require(devtools)
# install_github("TraME-Project/Shortest-Path-R")

#

rm(list=ls())
library(SPR)

# load data

thePath = getwd()
arcs = as.matrix(read.csv(paste0(thePath,"/NYC/arcs.csv"),sep=",", header=TRUE)) # loads the data
nodes = as.matrix(read.csv(paste0(thePath,"/NYC/nodes.csv"),sep=",", header=TRUE)) # loads the data
namesNodes = paste(nodes[,1],nodes[,7])

arcs <- matrix(as.numeric(arcs[,c(1,2,3)]),ncol=3)

nbNodes = max(arcs[,1])

# set source and destination nodes

originNode <- 452 #Union Sq
destinationNode <- 471  #59 St

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
