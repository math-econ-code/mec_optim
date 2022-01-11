import numpy as np
import scipy.sparse as spr
import gurobipy as grb

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

    def M_z_a(self):
        return spr.vstack([spr.kron(spr.identity(self.nbx), np.ones((1,self.nby))),spr.kron(np.ones((1,self.nbx)),spr.identity(self.nby))])

    def q_z(self):
        return np.concatenate([self.n_x,self.m_y])
        
    def solve_full_lp(self, OutputFlag= True):
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


    def solve_full_lp(self,OutputFlag=True):
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
        else:
            raise ValueError('Optimization failed.')
            
        return (μopt_a.reshape((self.nbx,-1)),uopt_x,vopt_y)