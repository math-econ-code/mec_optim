library(Matrix)
print(Diagonal(10)) # identity matrix
permMat = sparseMatrix(i = 1:10, j = c(3,5,2,7,10,4,9,8,1,6), dims = c(10, 10), x = 1) # a permutation matrix
print(permMat)
print(solve(permMat)) # inverse matrix is full
print(Diagonal(10) + matrix(1,10,10)) # sum with a full matrix is full
print(Diagonal(10) + permMat) # sum with a sparse matrix is sparse
print(Diagonal(10) %*%  matrix(1,10,10)) # product with a full matrix is full
print(Diagonal(10) %*%  permMat) # product with a sparse matrix is sparse
print(Diagonal(10) + 1) # sum with a scalar is full
print(2*Diagonal(10)) # product by a scalar is sparse
print(kronecker ( Diagonal(3), matrix(1,3,1) )) # kronwcker with a full matrix is sparse
