
f = function (x) 
{
  if (x>0) {
    return(1)
  } else {
    return(-1)
  }
}

print(f(c(0,1))) # wrong! 

fvec = Vectorize(f)
print(fvec(c(0,1))) # correct!

fbis = function (x) (ifelse(x>0,1,-1))
print(fbis(-5:5)) # correct


# Example of use for plotting a function
xs = runif(100)
thequantilemap = Vectorize(function (t) (quantile(xs,t)))
ts = (0:100)/100
vals = thequantilemap(ts)
plot(x = ts,y = thequantilemap(ts),type = 'l' )