import numpy as np
import scipy.sparse as spr
import gurobipy as grb
from time import time
from scipy.stats import entropy
from sklearn import linear_model



def sum_xlogx(a): # added on D3
    s=a.sum()
    return s*np.log(s) - s * entropy(a.flatten(),axis=None)

def display( args ):
    μ_x_y,u_x,v_y,valobs,valtot,iterations, taken,name = args
    print('*'*60)
    print('*'* (30 -len(name) // 2) + '  '+name + '  ' + '*'*(26 - (1+len(name)) // 2 ) )
    print('*'*60)
    print('Converged in ', iterations, ' steps and ', taken, 's.')
    print('Sum(mu*Phi)+σ*Sum(mu*log(mu))= ', valtot)
    print('Sum(mu*Phi)                = ', valobs)
    print('*'*60)
    return 

class OTProblem: 
    def __init__(self,Φ_x_y,n_x=None,m_y=None):
        self.Φ_a = Φ_x_y.flatten()
        self.nbx , self.nby = Φ_x_y.shape # number of types on each parts
        self.nbz = self.nbx + self.nby # total number of types 
        self.nba = self.nbx * self.nby # number of arcs
        if n_x is None: 
            self.n_x = np.ones(self.nbx)
        else:
            self.n_x = n_x
        if m_y is None:
            self.m_y = np.ones(self.nby)
        else:
            self.m_y = m_y

    def M_z_a(self): # added on D1
        return spr.vstack([spr.kron(spr.identity(self.nbx), np.ones((1,self.nby))),spr.kron(np.ones((1,self.nbx)),spr.identity(self.nby))])

    def q_z(self): # added on D1
        return np.concatenate([self.n_x,self.m_y])
        
    def solve_full_lp(self, OutputFlag= True): # added on D1
        m=grb.Model()
        μ_a = m.addMVar(self.nba)
        m.setObjective(self.Φ_a @ μ_a, grb.GRB.MAXIMIZE)
        m.addConstr(self.M_z_a() @ μ_a == self.q_z())
        m.setParam( 'OutputFlag', OutputFlag )
        m.optimize()
        if m.status == grb.GRB.Status.OPTIMAL:
            μopt_a = np.array(m.getAttr('x')).reshape(self.nbx,self.nby)
            popt_z = m.getAttr('pi')
            uopt_x, vopt_y = popt_z[:self.nbx],popt_z[self.nbx:]
        return μopt_a.reshape((self.nbx,-1)),uopt_x,vopt_y


    def solve_partial_lp(self, OutputFlag = True):
        m=grb.Model()
        μ_a = m.addMVar(self.nba)
        m.setObjective(self.Φ_a @ μ_a, grb.GRB.MAXIMIZE)
        m.addConstr(self.M_z_a() @ μ_a <= self.q_z())
        m.setParam( 'OutputFlag', OutputFlag )
        m.optimize()
        if m.status == grb.GRB.Status.OPTIMAL:
            μopt_a = np.array(m.getAttr('x')).reshape(self.nbx,self.nby)
            popt_z = np.array(m.getAttr('pi'))
            uopt_x, vopt_y = popt_z[:self.nbx],popt_z[self.nbx:]
        return (μopt_a.reshape((self.nbx,-1)),uopt_x,vopt_y)


    def matrixIPFP(self,σ , tol = 1e-9, maxite = 1e+06 ): # added on D3
        ptm = time()
        ite = 0
        K_x_y = np.exp(self.Φ_a / σ).reshape(self.nbx,-1)
        B_y = np.ones(self.nby)
        error = tol + 1
        while error > tol and ite < maxite:
            A_x = self.n_x / (K_x_y @ B_y)
            KA_y = (A_x.T @ K_x_y)
            error = (abs(KA_y * B_y / self.m_y)-1).max()
            B_y = self.m_y / KA_y
            ite = ite + 1
            
        u_x,v_y = - σ * np.log(A_x),- σ * np.log(B_y)
        μ_x_y = K_x_y * A_x.reshape((-1,1)) * B_y.reshape((1,-1))
        valobs = self.Φ_a.dot(μ_x_y.flatten())
        valtot =  valobs - σ * sum_xlogx(μ_x_y)
        taken = time() - ptm
        if ite >= maxite:
            print('Maximum number of iteations reached in matrix IPFP.')    
        return μ_x_y,u_x,v_y,valobs,valtot,ite, taken, 'matrix IPFP'


    def logdomainIPFP_with_LSE_trick(self,σ , tol = 1e-9, maxite = 1e+06 ): # added on D3
        ptm = time()
        ite = 0
        Φ_x_y = self.Φ_a.reshape(self.nbx,-1)
        v_y = np.zeros(self.nby)
        λ_x,ζ_y = - σ * np.log(self.n_x), - σ * np.log(self.m_y)
        error = tol + 1
        while error > tol and ite < maxite:
            vstar_x = (Φ_x_y - v_y.reshape((1,-1))).max( axis = 1)
            u_x = λ_x + vstar_x + σ * np.log( (np.exp((Φ_x_y - vstar_x.reshape((-1,1)) - v_y.reshape((1,-1)))/σ)).sum( axis=1) )
            ustar_y = (Φ_x_y - u_x.reshape((-1,1)) ).max( axis = 0)
            KA_y = (np.exp((Φ_x_y -u_x.reshape((-1,1)) - ustar_y.reshape((1,-1)) ) / σ)).sum(axis=0)
            error = np.max(np.abs(KA_y * np.exp( (ustar_y-v_y) / σ) / self.m_y - 1))
            v_y = ζ_y + ustar_y+ σ * np.log(KA_y)
            ite = ite + 1
        μ_x_y =np.exp((Φ_x_y -u_x.reshape((-1,1)) - v_y.reshape((1,-1)))/σ )
        valobs = self.Φ_a.dot(μ_x_y.flatten())
        valtot =  valobs - σ * sum_xlogx(μ_x_y)
        taken = time() - ptm
        if ite >= maxite:
            print('Maximum number of iteations reached in log-domain IPFP with LSE trick.')
        return μ_x_y,u_x,v_y,valobs,valtot,ite, taken, 'log-domain IPFP with LSE trick'


    def solveGLM(self,σ , tol = 1e-9): # added on D3
        ptm = time()
        muhat_a = (self.n_x.reshape((self.nbx,-1)) @ self.m_y.reshape((-1,self.nby))).flatten() / self.n_x.sum()
        ot_as_glm = linear_model.PoissonRegressor(fit_intercept=False,tol=tol ,verbose=3,alpha=0)
        ot_as_glm.fit( - self.M_z_a().T, muhat_a * np.exp(-self.Φ_a / σ) , sample_weight = np.exp(self.Φ_a / σ))
        
        p = σ * ot_as_glm.coef_
        u_x,v_y  = p[:self.nbx] - p[0], p[self.nbx:]+p[0]
        μ_x_y =np.exp((self.Φ_a.reshape((self.nbx,-1)) -u_x.reshape((-1,1)) - v_y.reshape((1,-1)))/σ )
        valobs = self.Φ_a.dot(μ_x_y.flatten())
        valtot =  valobs - σ * sum_xlogx(μ_x_y)
        taken = time() - ptm
        return μ_x_y,u_x,v_y,valobs,valtot,None, taken, 'GLM'