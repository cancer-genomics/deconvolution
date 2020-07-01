library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code")
args <-  commandArgs(trailingOnly=TRUE)

n.thin <- 20
iter <- 20*1000

dat <- readRDS("/dcl01/scharpf1/data/aarun/100kb_deconvolution.rds")
dat <- dat %>% mutate(total=short.cor+long.cor)
dat$total[!is.finite(dat$total)] <- 0

mafs <- readRDS("/dcl01/scharpf1/data/aarun/tumor_fractions.rds")

#one sample
group.num <- 1
dat <- dat %>% filter(group==group.num)
y <- dat %>% filter(sample=="plasma")
wbc <- dat %>% filter(sample=="buffy")
tumor <- dat %>% filter(sample=="tumor")
normal <- dat %>% filter(sample=="normal")

#temporary fix, maybe replace with mean of the arm its on
y$total[y$total < 0] <- 0

#spacing <- cumsum(rle(y$arm)$lengths)
#spacing <- c(0, spacing)
spacing <- seq(1,26200,100)
spacing[1] <- 0
spacing[length(spacing)] <- 26238


log.status <- as.character(args[1])
if (log.status=="log"){
data <- list(y=round(y$total), wbc=log(wbc$total), normal=log(normal$total), tumor=log(tumor$total), n=spacing)
} else{
    data <- list(y=round(y$total), wbc=wbc$total, normal=normal$total, tumor=tumor$total, n=spacing)
}

z.status <- as.character(args[2])

modeltype <- paste0(log.status, "_",z.status)
print(modeltype)

if (z.status=="z"){
    if (log.status=="log"){
        fit <- jags.model("single_model/model/log_nint.jag", data=data, n.chains=2)
    } else{
        fit <- jags.model("single_model/model/nlog_nint.jag",data=data,n.chains=2)
    }

    samples <- coda.samples(fit, variable.names=c("b2", "z", "p"), n.iter=iter, thin=n.thin)
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

print(mult.mean)
print(cond.exp)

} else{
    if (log.status=="log"){
        fit <- jags.model("single_model/model/no_z/log_nint.jag", data=data, n.chains=2)
    } else{
        fit <- jags.model("single_model/model/no_z/nlog_nint.jag", data=data, n.chains=2)
}
    samples <- coda.samples(fit, variable.names=c("b2"), n.iter=iter, thin=n.thin)
   samples <-  ggs(samples)
   b2.mean <- mean(samples$value)
   print(b2.mean)
}  


true.tf <- mafs[group.num, ]
print(true.tf)

saveRDS(samples, paste0("single_model/real_data/", modeltype, ".rds"))
