library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code")


args <- commandArgs(trailingOnly=TRUE)

lambdas <- c(300, 400, 500)
bins <- 50000
wbc <- rpois(bins, lambdas[1])
normal <- rpois(bins, lambdas[2])
tumor <- rpois(bins, lambdas[3])

groups <- 500

groups.w.tumor <- as.numeric(args[1])
tumor.fraction <- as.numeric(args[2])


tumor.contributions <- c(1:round(bins*groups.w.tumor))

normal.input <- runif(1, 0, tumor.fraction)
tumor.input <- tumor.fraction - normal.input

means <- wbc[tumor.contributions]*(1-tumor.fraction) + normal[tumor.contributions]*(normal.input) + tumor[tumor.contributions]*(tumor.input)

all.wbc.bins <- c((tail(tumor.contributions,n=1)+1):bins)
means.unaffected <- wbc[all.wbc.bins]
plasma.means <- c(means, means.unaffected)

y <- rpois(bins, plasma.means)

spacing <- seq(0, bins, bins/groups)

data <- list(y=y, wbc=log(wbc), normal=log(normal), tumor=log(tumor), n=spacing)
fit <- jags.model("single_model/model.jag",
                  data=data,
                  n.chains=1)
    
samples <- coda.samples(fit, variable.names=c("b2", "z", "p"),
                        n.iter=10000,
                        thin=10)

samples <- ggs(samples)

param.values <- unique(samples$Parameter)
keep.b2 <- grep("b2",param.values)
keep.z <- grep("z",param.values)
keep.b2 <- param.values[keep.b2]
keep.z <- param.values[keep.z]

extract.z <- samples %>% filter(Parameter %in% keep.z) %>% select(value)
extract.b2 <- samples %>% filter(Parameter %in% keep.b2) %>% select(value)

mult.mean <- mean(extract.z$value*extract.b2$value)
tumor.derived <- which(extract.z$value==1)
cond.exp <- mean(extract.b2$value[tumor.derived])
true.tf <- tumor.fraction*groups.w.tumor

print("entry")
print(mult.mean)
print(cond.exp)
print("here comes the truth")
print(true.tf)

saveRDS(samples, "single_model/res.rds")

#what sort of analyses do we want out of this?
#results should be exactly what we got before or damn near close
#what does p represent?

