library(tidyverse)
library(ggmcmc)
library(rjags)
#library(fs)
setwd("/dcl01/scharpf1/data/aarun/deconvolution/code")

if (!dir.exists("output_sim")){
    dir.create("output_sim")
}

lambdas <- c(300, 400)
bins <- 50000
wbc <- rpois(bins, lambdas[1])
normal <- rpois(bins, lambdas[2])

groups <- 500
grouplength <- bins / groups
groups.w.tumor <- 0.1
tumor.fraction <- 0.05

tumor.contributions <- c(1:round(bins*groups.w.tumor))

means <- wbc[tumor.contributions]*(1-tumor.fraction) + normal[tumor.contributions]*(tumor.fraction)
all.wbc.bins <- c((tail(tumor.contributions,n=1)+1):bins)
means2 <- wbc[all.wbc.bins]
plasma.means <- c(means, means2)

y <- rpois(bins, plasma.means)

chunker <- function(x,n){
     split(x, cut(seq_along(x), n, labels = FALSE))
}

y.chunk <- chunker(y, groups)
wbc <- log(wbc)
normal <- log(normal)
wbc.chunk <- chunker(wbc, groups)
normal.chunk <- chunker(normal,groups)

estimates.wbc <- numeric(groups)
estimates.z <- numeric(bins)


for (iter in 1:groups){
    data <- list(y=y.chunk[[iter]], wbc=wbc.chunk[[iter]], normal=normal.chunk[[iter]])
    fit <- jags.model("sim_genome.jag",
                  data=data,
                  inits=list(b1=c(0.05, 0.95)),
                  n.chains=1)
    
    samples <- coda.samples(fit, variable.names=c("b1", "z"),
                        n.iter=10000,
                        thin=10)
    samples2 <- ggs(samples)


    samples.wbc <- samples2 %>% filter(Parameter=="b1[2]")
    wbc.estimate <- mean(samples.wbc$value)

    samples3 <- samples2 %>% filter(!Parameter %in% c("b1[1]","b1[2]"))
    
    z.summary <- samples3 %>% group_by(Parameter) %>% summarize(values=tail(value,1))

    estimates.wbc[iter] <- wbc.estimate
    estimates.z[(((iter-1)*grouplength) + 1):(iter*grouplength)] <- z.summary$values

    spotchecks <- sample(iter, n=5, replace=FALSE)
    
    if (iter %in% spotchecks){
        file <- paste0("output_sim/wbc_frac_",iter,".pdf")
        out <- ggs_traceplot(samples.wbc) +
            ylim(c(0, 1))  +
            theme_bw() +
            ylab("") +
             geom_hline(yintercept=0.95)
        ggsave(file, out,  width=10, height=10, units="in")
    }
}
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


