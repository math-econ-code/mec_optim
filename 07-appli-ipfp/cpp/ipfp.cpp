/*
 * A C++ version of ipfp.R
 *
 * Keith O'Hara
 * 06/21/2018
 */

#include "armadillo"

int main()
{
    const int max_iter = 1000000;
    const double err_tol = 1E-9;

    const double sigma = 0.1;

    //

    bool do_ipfp1 = false;

    int nbX = 10;
    int nbY = 8;

    //

    arma::mat Phi = arma::randu(nbX,nbY);

    arma::vec p(nbX); p.fill(1.0/nbX);
    arma::vec q(nbY); q.fill(1.0/nbY);

    //
    // IPFP2

    int iter = 0;
    double err_val = std::max(1.0,err_tol);

    arma::mat pi_mat;
    double val;

    if (do_ipfp1)
    {
        // IPFP 1
        arma::mat K = arma::exp(Phi / sigma);
        arma::vec B = arma::ones(nbY,1);

        arma::vec A;

        while (err_val > err_tol && iter < max_iter)
        {
            iter++;

            A = p / (K * B);

            arma::vec KA = K.t() * A;

            err_val = arma::max(arma::abs( KA % B / q - 1.0 ));

            B = q / KA;
        }

        pi_mat = K % arma::repmat(A,1,nbY) % arma::repmat(B.t(),nbX,1);
        val = arma::accu(pi_mat % Phi) - sigma * arma::accu(pi_mat % arma::log(pi_mat));

    }
    else
    {
        // IPFP 2
        arma::vec mu = -sigma * arma::log(p);
        arma::vec nu = -sigma * arma::log(q);

        arma::vec u = arma::zeros(nbX,1);
        arma::vec v = arma::zeros(nbY,1);

        arma::vec u_old(nbX);
        u_old.fill(1E10);

        while (err_val > err_tol && iter < max_iter)
        {
            iter++;

            arma::vec vstar = arma::max(Phi - arma::repmat(v.t(),nbX,1),1);

            u = mu + vstar + sigma * arma::log( arma::sum( arma::exp( (Phi - arma::repmat(v.t(),nbX,1) - arma::repmat(vstar,1,nbY))/sigma ), 1 ) );

            err_val = arma::max(arma::abs( u - u_old ));

            u_old = u;

            //

            arma::vec ustar = arma::trans(arma::max(Phi - arma::repmat(u,1,nbY),0));

            v = nu + ustar + sigma * arma::trans(arma::log( arma::sum( arma::exp( (Phi - arma::repmat(u,1,nbY) - arma::repmat(ustar.t(),nbX,1))/sigma ), 0 ) ));
        }

        pi_mat = arma::exp( (Phi - arma::repmat(u,1,nbY) - arma::repmat(v.t(),nbX,1))/sigma );
        val = arma::accu(pi_mat % Phi) - sigma * arma::accu(pi_mat % arma::log(pi_mat));

    }

    //

    arma::cout << "pi:\n" << pi_mat << arma::endl;
    std::cout << "val = " << val << arma::endl;

    //

    return 0;
}
