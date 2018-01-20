
set.seed(777)
nObs = 1000   # num of observations
nFeature = 100
nonZero  = 10   # num of non-zero components

x = matrix(runif(nObs*nFeature, -1, 1), nObs, nFeature)
beta = c(1:nonZero, rep(0, nFeature-nonZero))
eps = 0.5 * rnorm(nObs)
y = x %*% beta + eps

plot(y)

summary(lm(y ~ 0 + x))$coefficients

library(glmnet)

fit = glmnet(x, y, intercept = FALSE, alpha = 1)

plot(fit)

cvfit = cv.glmnet(x, y, intercept = FALSE, alpha = 1, nfolds=5)

plot(cvfit)

cvfit$lambda.1se

coef(cvfit, s = "lambda.1se")

summary(lm(y ~ 0 + x[,1:10]))$coefficients
