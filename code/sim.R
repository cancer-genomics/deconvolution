library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/models")

args = commandArgs(trailingOnly=TRUE)

num.components <- as.numeric(args[1])

lambdas <- c(300,400,500)
n <- 10000
wbc <- rpois(n, lambdas[1])
normal <- rpois(n, lambdas[2])
tumor <- rpois(n, lambdas[3])

tumor.fraction <- as.numeric(args[2])

if (num.components==2){
    means <- tumor.fraction*normal + (1-tumor.fraction)*wbc
    y <- rpois(n, means)
    data <- list(y=y, wbc=log(wbc), normal=log(normal))
    dir <- "two_comp"
} else{
    tf <- tumor.fraction /2
    means <- tf*normal + tf*tumor + (1-tumor.fraction)*wbc
    y <- rpois(n, means)
    data <- list(y=y, wbc=log(wbc), normal=log(normal), tumor=log(tumor))
    dir <- "three_comp"
}

model.type <- as.character(args[3])

if (model.type=="woz"){
    model <- paste0(dir,"/simple.jag")
    fit <- jags.model(model,data=data, n.chains=1)
    samples <- coda.samples(fit, variable.names="b2", n.iter=10000, thin=10) %>%  ggs()

} else{
    model <- paste0(dir, "/with_z.jag")
    fit <- jags.model(model, data=data, n.chains=1)
    samples <- coda.samples(fit, variable.names=c("b2","z"), n.iter=10000, thin=10) %>% ggs()
}

id <- paste0(args, collapse="_")
out <- paste0("results/", id,".rds")
samples$id <- id
saveRDS(samples, out)
