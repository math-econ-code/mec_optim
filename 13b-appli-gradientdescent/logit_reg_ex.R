
rm(list=ls())
set.seed(2018)

sigm <- function(x)
{
    return( 1 / (1 + exp(-x)) )
}

n_dim <- 5
n_samp <- 1000

X <- matrix(rnorm(n_dim*n_samp),ncol=n_dim)
theta_0 <- matrix(runif(n_dim,1,4))

mu <- sigm(X%*%theta_0)

y <- numeric(n_samp)

for (i in 1:n_samp)
{
    y[i] <- rbinom(1,1,mu[i])
}


#

fn <- function(theta,y,X) {
    mu <- sigm(X%*%theta)
    
    val <- y*log(mu) + (1-y)*log(1-mu)
    
    return(-sum(val))
}

grr <- function(theta,y,X) {
    mu <- sigm(X%*%theta)
    return( t(X)%*% (mu - y) )
}

x0 <- rep(1,n_dim)

optim(par=x0,fn=fn,gr=grr,y=y,X=X,method="BFGS")



