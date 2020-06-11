library(tidyverse)
library(ggmcmc)
library(rjags)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/single_model")


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


log.status <- as.character(args[3])
intercept.status <- as.character(args[4])

model.file <- paste0("model/",log.status, "_", intercept.status, ".jag")

if (log.status=="log"){
    data <- list(y=y, wbc=log(wbc), normal=log(normal), tumor=log(tumor), n=spacing)
} else{
    data <- list(y=y, wbc=wbc, normal=normal, tumor=tumor, n=spacing)
}
fit <- jags.model(model.file,
                  data=data,
                  n.chains=1)

samples <- coda.samples(fit, variable.names=c("b2", "z", "p"),
                        n.iter=20000,
                        thin=20)
samples <- ggs(samples)

param.values <- unique(samples$Parameter)
keep.b2 <- grep("b2",param.values)
keep.z <- grep("z",param.values)
keep.p <- grep("p", param.values)
keep.p <- param.values[keep.p]
keep.b2 <- param.values[keep.b2]
keep.z <- param.values[keep.z]

extract.z <- samples %>% filter(Parameter %in% keep.z) %>% select(value)
extract.b2 <- samples %>% filter(Parameter %in% keep.b2) %>% select(value)
extract.p <- samples %>% filter(Parameter %in% keep.p) %>% select(value)

p.mean <- mean(extract.p$value)
mult.mean <- mean(extract.z$value*extract.b2$value)
tumor.derived <- which(extract.z$value==1)
cond.exp <- mean(extract.b2$value[tumor.derived])
true.tf <- tumor.fraction*groups.w.tumor


print(true.tf)
print(p.mean)

bias.mult <- mult.mean - true.tf
bias.cond <- cond.exp - true.tf



#multmean.value <- extract.z$value*extract.b2$value
#condexp.value <- extract.b2$value[tumor.derived]

#ci <- function(x, nboot=1000){
#	mu_bar <- mean(x)
#	len <- length(x)
#	mu_star <- unlist(lapply(1:nboot, function(dummy) mean(sample(x, replace=TRUE, len))))
##	delta <- mu_star - mu_bar
#	delta <- sort(delta)
	
#	confint <- c(round(nboot*0.05), round(nboot*0.95))
#	val <- c(mu_bar + delta[confint[1]], mu_bar + delta[confint[2]])
#	return(val)
#}

standards <- c(7,6,3,2)
key <- (groups.w.tumor + tumor.fraction) * 10
sim.number <- grep(key, standards)

type.num <- str_count(paste0(log.status, intercept.status), "n")
if (type.num==3){
    col.num <- c(7,8)
} 
if (type.num==1){
    col.num <- c(1,2)
}
if (type.num==2){
    if (grepl("login", paste(log.status, intercept.status))){
        col.num <- c(3,4)
    } else{
        col.num <- c(5,6)
    }
}

items <- readRDS("experiment.rds")
items[sim.number, col.num] <- c(bias.mult, bias.cond)

saveRDS(items, "experiment.rds")

fileoutput <- paste0("output/",log.status,"_",intercept.status,"/",groups.w.tumor,"_",tumor.fraction,".rds")
saveRDS(samples, fileoutput)

#what does p represent?

