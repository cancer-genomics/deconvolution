library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code")

dat <- readRDS("/dcl01/scharpf1/data/aarun/100kb_deconvolution.rds")
dat <- dat %>% mutate(total=short.cor+long.cor)
dat$total[!is.finite(dat$total)] <- 0

mafs <- readRDS("/dcl01/scharpf1/data/aarun/tumor_fractions.rds")

#one sample
dat <- dat %>% filter(group==1)
y <- dat %>% filter(sample=="plasma")
wbc <- dat %>% filter(sample=="buffy")
tumor <- dat %>% fitler(sample=="tumor")
normal <- dat %>% filter(sample=="normal")

spacing <- cumsum(rle(y$arm)$lengths)
spacing <- c(0, spacing)

data <- list(y=y$total, wbc=log(wbc$total), normal=log(normal$total), tumor=log(tumor$total), n=spacing)

#can scale to more samples
#can increase n.iter, and thin 
#can increase # of chains

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

print(mult.mean)
print(cond.exp)
print("the truth is 0.112, 0.228 or 0.304 acc adhoc maf delfi and ichor respectively")


saveRDS(samples, "single_model/real_data/res.rds")


