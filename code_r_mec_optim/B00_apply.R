
tst = array(1:24,dim=c(4,3,2))
print(c(tst))

print(apply(X = tst,MARGIN = 1,FUN = mean))
print(apply(X = tst,MARGIN = 2,FUN = mean))
print(apply(X = tst,MARGIN = 3,FUN = mean))
print(apply(X = tst,MARGIN = c(1,3),FUN = mean)) 




