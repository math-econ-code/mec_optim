library(rgdal)
library(sf)
library(sp)
library(raster)
library(ggplot2)
library(gurobi)
library(Matrix)

taxi_zones = st_read("/Users/Octavia/Desktop/taxi_zones/taxi_zones.shp")
zones = st_geometry(taxi_zones)
cntrd = st_centroid(zones)

plot(zones, add = TRUE, border= 'grey')
plot(cntrd, col = 'red', add = TRUE, cex = .1)

n_zones = length(zones)
n_clients = length(green_tripdata_2017_01$PULocationID)

# Estimate demand per zone
p <- rep(0,n_zones)
for (i in 1:n_zones) {
  p[i] <- (length(which(green_tripdata_2017_01$PULocationID == i)))
}

n_clients <- sum(p)
p<-p/sum(p)
#Impose uniform distribution of taxis 
q <- (rep(1/n_zones,n_zones))

#Distance function
for (i in 1:n_zones) {
  for (j in 1:n_zones){
    Phi[i,j] <- st_distance(cntrd[i],cntrd[j])
  }
}
Phi<- as.matrix(-Phi)

N = n_zones
M = n_zones

c=c(Phi)
A1 = kronecker(matrix(1,1,M),sparseMatrix(1:N,1:N))
A2 = kronecker(sparseMatrix(1:M,1:M),matrix(1,1,N))
A = rbind2(A1,A2)

d = c(p,q) 

result   = gurobi ( list(A=A,obj=c,modelsense="max",rhs=d,sense="="), params=list(OutputFlag=0) ) 
if (result$status=="OPTIMAL") {
  pi = matrix(result$x,nrow=N)
  u = result$pi[1:N]
  v = result$pi[(N+1):(N+M)]
  val = result$objval
} else {stop("optimization problem with Gurobi.") }




