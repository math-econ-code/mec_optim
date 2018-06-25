/*
 * A C++ version of busmaintenance.R
 *
 * Keith O'Hara
 * 06/21/2018
 */

#include "armadillo"

inline
double
maint_cost(const double x)
{
    return x*5E2;
}

int main()
{
    int nbX = 10;
    int nbY = 2;    // choice set: 1=run as usual; 2=overhaul

    int nbT = 40;

    //

    const double overhaul_cost = 8E3;
    const double beta = 0.9;

    //

    double prob_par = 0.75; // probability of remaining in the same state

    arma::mat P = arma::zeros(nbX,nbX);

    P.diag().fill(prob_par);
    P.diag(1).fill(1.0-prob_par);
    P(nbX-1,0) = 1.0 - prob_par;

    P = arma::join_cols(P,arma::join_rows(arma::ones(nbX,1),arma::zeros(nbX,nbX-1)));

    arma::cout << "P:\n" << P << arma::endl;

    //

    arma::mat u_xy(nbX,nbY);

    for (int i=0; i<nbX-1; i++)
    {
        u_xy(i,0) = -maint_cost(i+1.0);
    }

    u_xy(nbX-1,0) = -overhaul_cost;
    u_xy.col(1).fill(-overhaul_cost);

    // arma::cout << "u_xy:\n" << u_xy << arma::endl;

    //
    // backward induction

    arma::vec cont_vals = arma::max(std::pow(beta,nbT) * u_xy, 1);

    arma::mat U_xt(nbX,nbT);
    U_xt.col(nbT-1) = cont_vals;

    for (int t=nbT-1; t > 0; t--)
    {
        arma::mat myopic = std::pow(beta,t) * u_xy;
        arma::mat E_cont_vals = arma::reshape(P * cont_vals,nbX,2);

        cont_vals = arma::max(myopic + E_cont_vals, 1);

        U_xt.col(t-1) = cont_vals;
    }

    arma::cout << "U_x1:\n" << U_xt.col(0) << arma::endl;

    //

    return 0;
}
