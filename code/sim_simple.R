library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code")

lambdas <- c(300,400)

n <- 10000
wbc <- rpois(n,lambdas[1])
normal <- rpois(n,lambdas[2])
tumor.fraction <- 0.3
means <- tumor.fraction*normal + (1-tumor.fraction)*wbc
y <- rpois(n, means)

data <- list(y=y,wbc=log(wbc),normal=log(normal))

fit <- jags.model("sim_mixmodel.jag",data=data, inits=list(b1=c(0.3,0.7)), n.chains=3)
samples <- coda.samples(fit, variable.names=c("b1","b0", "z"), n.iter=10000, thin=10) %>%  ggs()

saveRDS(samples, "output_sim/check_sim.rds")
