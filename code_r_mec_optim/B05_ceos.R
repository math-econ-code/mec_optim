#################################################
###############  math+econ+code   ###############
#################################################
##########       Alfred Galichon       ##########
#################################################
#
#

cdf_P = punif
quantile_P = qunif

cdf_Q = pnorm
quantile_Q = qnorm

Phi = function(x,y) (x*y)
dPhi_dx = function(x,y) (y)
dPhi_dy = function(x,y) (x)


Tx = function (x) (quantile_Q(cdf_P(x)))
Tinvy = function (y) (quantile_P(cdf_Q(y)))

ux = function(x) (integrate(f = function(z) (dPhi_dx(z,Tx(z))),lower = 0,upper = x )$value)
vy = function(y) (integrate(f = function(z) (dPhi_dy(Tinvy(z),z)),lower = Tx(0),upper = y )$value
                  ) - Phi(0,Tx(0))


