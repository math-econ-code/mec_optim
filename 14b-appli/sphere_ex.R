
fn <- function(x)
{
    return(sum(x^2))
}

gn <- function(x)
{
    return(2*x)
}

n <- 10

x0 <- rep(2,n)

optim(x0,fn,gn,method="BFGS")
