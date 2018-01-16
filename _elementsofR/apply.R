
tst = array(1:24,dim=c(4,3,2))
c(tst)
print(apply(X = tst,MARGIN = 1,FUN = mean))
print(apply(X = tst,MARGIN = 2,FUN = mean))
print(apply(X = tst,MARGIN = 3,FUN = mean))

print(apply(X = tst,MARGIN = c(1,3),FUN = mean)) 



# max and pmax
print(max(1:3,4:6))
print(pmax(1:3,4:6))
print(apply(X = tst,MARGIN = 1,FUN = max))
print(apply(X = tst,MARGIN = 1,FUN = pmax))

