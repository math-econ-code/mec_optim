X = rbind(c(1,4),
          c(2,5),
          c(3,6))
B = rbind(c(2,2),
          c(2,2))
I2 = diag(2)

A = matrix(rep(1,3),1,3)
print(I2)
print(kronecker(X,I2))
print(kronecker(I2,X))

print(c(A %*% X %*% B))
print(c(kronecker (t(B),A) %*% c(X)))
