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
##            PE 5.1: Power diagrams           ##
#################################################
#
#
#################################################
# Requires packages 'transport' and 'geometry'
################################################

library('magick')
library('transport')
library('geometry')

SEED <- 777
MAX_ITER <- 1000
PREC <- 1E-2

set.seed(SEED)
nCells <- 10

y1 <- runif(nCells)
y2 <- runif(nCells)
vtilde <- rep(0,nCells)
q <- rep(1/nCells,nCells)
demand <- rep(0,nCells)


# create canvas
frames <- image_graph(width = 600, height = 1200, res = 150)

pwd <- power_diagram(y1,y2,vtilde,rect=c(0,1,0,1))
plot(pwd,weights=FALSE)



t <- 1
cont <- TRUE
while((cont==TRUE) && (t<MAX_ITER))
{
  print(t)
  for (j in 1:nCells)
  {
    cellj <-pwd$cells[[j]]
  demand[j] <- polyarea(cellj[,1],cellj[,2])
  }
  if (max(abs(demand-q))<PREC/nCells) 
  {cont<-FALSE} 
  else 
  {
    t<-t+1
    vtilde <- vtilde - 0.1 * (demand - q)
    pwd <- power_diagram(y1,y2,vtilde,rect=c(0,1,0,1))
    plot(pwd,weights=FALSE)
  }
}

#done with plotting
dev.off()

# animate
image_animate(frames, ..1)

# Using Rgeogram from TraMe
library(Rgeogram)
vtilde_alt = otm2D(cbind(y1,y2),weights = q)$weights
