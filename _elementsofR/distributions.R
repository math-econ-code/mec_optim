# normal distribution
print(dnorm(0)) # density of the normal distribution
print(pnorm(1)) # cdf of the normal distribution
print(qnorm(0.05)) # quantile of the normal distribution

# empirical distributions
nobs = 100
xs = runif(nobs)
thequantilemap = Vectorize(function (t) (quantile(xs,t)))
ts = (0:100)/100
vals = thequantilemap(ts)
plot(x = ts,y = thequantilemap(ts),type = 'l' )
