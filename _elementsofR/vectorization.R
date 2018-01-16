tst = rbind(c(1,4),
            c(2,5),
            c(3,6)
            )
print(tst)
print(c(tst))
print(matrix(tst,2,3))

I2 = diag(2)
print(I2)
print(kronecker(tst,I2))
print(kronecker(I2,tst))

tst3 = array(1:27,dim=c(3,3,3))
print(c(tst3[1,1,1], tst3[2,1,1], tst3[3,1,1],
        tst3[1,2,1], tst3[2,2,1], tst3[3,2,1],
        tst3[1,3,1], tst3[2,3,1], tst3[3,3,1],
        tst3[1,1,2], tst3[2,1,2], tst3[3,1,2],
        tst3[1,2,2], tst3[2,2,2], tst3[3,2,2],
        tst3[1,3,2], tst3[2,3,2], tst3[3,3,2],
        tst3[1,1,3], tst3[2,1,3], tst3[3,1,3],
        tst3[1,2,3], tst3[2,2,3], tst3[3,2,3],
        tst3[1,3,3], tst3[2,3,3], tst3[3,3,3]))

