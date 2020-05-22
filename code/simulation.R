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

fit <- jags.model("sim_mixmodel.jag",
                  data=data,
                  inits=list(b1=c(0.99, 0.01)),
                  n.chains=3)
samples <- coda.samples(fit, variable.names=c("b1", "b0"),
                        n.iter=10000,
                        thin=10)
##samples2 <- samples %>% filter(Parameter %in% c('b1[1]','b1[2]'))
samples2 <- ggs(samples, family="b1") %>%
    filter(Parameter=="b1[1]")
ggs_traceplot(samples2) +
    ylim(c(0.5, 1))  +
    theme_bw() +
    ylab("") +
    geom_hline(yintercept=0.99)
##
## Next steps
## 
## - What happens with wbc contribution is 1 and normal is zero *
##
## - 50000 bins
## - 500 groups of 100
## - 10% of the groups are .95 and .05, rest are 1 and 0
##
## proportion of group that have a contribution from the tumor
##
## log(theta) = b0 + (b1 * wbc + (1-b1)*tumor)*z + (b1 * wbc)(1-z)
## z ~ dbin(pi, 1) ##
## pi ~ beta(1, 1)



##m <- spread(samples2, Parameter, value)
##coda::effectiveSize(m[[3]])


