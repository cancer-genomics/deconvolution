library(rstan)
N <- 5000
lambda <- c(5, 15) # poisson parameters
theta <- c(0.3, 0.7) # mixing proportions
set.seed(1)
z <- sample(1:2, N, replace=TRUE, prob=theta)
y <- rpois(N, lambda[z])
table(y)
stancode <- "
data {
    // data
    int N; // number observations
    int y[N]; // observations
}
parameters {
    ordered[2] lambda;
    simplex[2] theta;
}
model {
    real contributions[2];
    // prior
    lambda ~ exponential(0.1);
    theta ~ dirichlet(rep_vector(0.5, 2));
    for (n in 1:N) {
        for (k in 1:2) {
            contributions[k] = log(theta[k]) + poisson_lpmf(y[n] | lambda[k]);
        }
        target += log_sum_exp(contributions);
    }
}
"
model <- stan_model(model_code=stancode,
                    model_name="mixture")
stan_data <- list(N=N, y=y)
results <- sampling(model,
                    data=stan_data,
                    chains=4,
                    cores=4)
