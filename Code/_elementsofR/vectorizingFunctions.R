tst = function (x) (ifelse(x>0,1,-1))
print(tst(-5:5)) # correct

tst2 = function (x) 
{
  if (x>0) {
    return(1)
  } else {
    return(-1)
  }
}

print(tst2(-5:5)) # wrong! 

tst3 = Vectorize(tst2)

print(tst3(-5:5)) # correct again