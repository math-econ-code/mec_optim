v1 = 1:3
v2 = 1:3
v3 = 1:6
v4 = 1:7

print(v1*v2)

print(v1*v3)         # v1 has been repeated twice to fit the size of v3
print(c(v1,v1)*v3)   # gives the same result as above

print(v1*v4)         # we get a warning that length of v4 is not a multiple of that of v1

M = matrix(1:6,3,2) 

print(M)

# suppose we want to multiply the lines of m by entries of v = c(1,2,3)
v = 1:3
print(matrix(v,3,2))
print(M*matrix(v,3,2)) 
print(M*v)          # same result as above; m has been repeated twice and treated as a column


# now suppose we want to multiply the columns of m by entries of w = c(1,2)
w = c(1:2)
print(matrix(w,3,2,byrow = T))
print(M*matrix(w,3,2,byrow = T))
print(t(t(M)*w)) # same as above; note that we had to transpose M twice  
