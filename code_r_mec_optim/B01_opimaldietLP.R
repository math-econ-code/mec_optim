################################################# (c) by Alfred Galichon ##########

rm(list=ls())

library(gurobi)
library(tictoc)
library(Rglpk)

# setting up the data
thepath = paste0(getwd(),"/../data_mec_optim/lp_stigler-diet")
filename = "/StiglerData1939.txt"
thedata = as.matrix(read.csv(paste0(thepath, filename), sep = "\t", header = T))
nbCommodities = length(which(thedata[, 1] != "")) - 1
names = thedata[1:nbCommodities, 1]
themat = matrix(as.numeric(thedata[, 3:13]), ncol = 11)
themat[is.na(themat)] = 0

# calling Gurobi
N = t(themat[1:nbCommodities, 3:11])
d = themat[(nbCommodities + 1), 3:11]
c = rep(1, nbCommodities)

result = gurobi(list(A = N, obj = c, modelsense = "min", rhs = d, sense = ">"), params = list(OutputFlag = 0))
q_yearly = result$x * 365  # convert into yearly cost
pi = result$pi
cost_daily = result$objval

# display optimal solution
print("*** optimal solution ***")
toKeep = which(q_yearly != 0)
foods = q_yearly[toKeep]
names(foods) = names[toKeep]
print(foods)
print(paste0("Total cost (optimal)= ", sum(q_yearly * c)))
print("**************************")

# compare with Stigler's solution
print("*** Stigler's solution ***")
toKeepStigler = c(1, 15, 46, 52, 69)
foods_stigler = c(13.33, 3.84, 4.11, 1.85, 16.8)
names(foods_stigler) = names[toKeepStigler]
print(foods_stigler)
print(paste0("Total cost (Stigler)= ", sum(foods_stigler * c[toKeepStigler])))
print("**************************")


# alternatively, use glpk
print("*** Optimal solution using Rglpk ***")

resGlpk = Rglpk_solve_LP(obj = c, mat = N, dir = rep(">", length(d)), rhs = d, bounds = NULL, max = FALSE, control = list())
print(resGlpk$optimum * 365)
