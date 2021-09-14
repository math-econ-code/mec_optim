tst = rbind(c(1,4),
            c(2,5),
            c(3,6)
)
print(tst)
print(c(tst))
print(matrix(tst,2,3))


tst2 = array(0,dim=c(3,3,3))
for (i in 1:3) {
  for (j in 1:3){
    for (k in 1:3){
      tst2[i,j,k] = 100*i+10*j+k
    }
  }
}
print(c(tst2))