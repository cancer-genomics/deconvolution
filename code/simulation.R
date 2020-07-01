library(tidyverse)
library(ggmcmc)
library(rjags)
library(fs)
outdir <- file.path("..", "output", "simulation.R")
dir_create(outdir)
## increase spread between lambdas, model sucks more for tf = 0.3
## thinning doesnt help, high autocorrelation

lambdas <- c(300, 400)
n <- 5008
wbc <- rpois(n, lambdas[1])
normal <- rpois(n, lambdas[2])
tumor.fraction <- 0.99
means <- tumor.fraction*normal + (1-tumor.fraction)*wbc
y <- rpois(n, means)

data <- list(y=y, wbc=log(wbc), normal=log(normal))
dat <- list(y=y, wbc=wbc, normal=normal)

fit <- jags.model("sim_mixmodel.jag",
                  data=dat,
                  inits=list(b1=c(0.99, 0.01)),
                  n.chains=3)
samples <- coda.samples(fit, variable.names=c("b1", "b0"),
                        n.iter=1000,
                        thin=10)
##samples2 <- samples %>% filter(Parameter %in% c('b1[1]','b1[2]'))

## only need to plot one of the coefficients at this point
samples2 <- ggs(samples) %>%
    filter(Parameter=="b1[1]") 
ggs_traceplot(samples2) +
    theme_bw() +
    ylab("") +
    ylim(c(0.8, 1)) +
    geom_hline(yintercept=0.99)


