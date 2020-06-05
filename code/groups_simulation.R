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
directory <- paste("output_sim/groups",groups.w.tumor,"tf",tumor.fraction,sep="_")

dir.create(directory)

tumor.contributions <- c(1:round(bins*groups.w.tumor))

normal.input <- runif(1, 0, tumor.fraction)
tumor.input <- tumor.fraction - normal.input

means <- wbc[tumor.contributions]*(1-tumor.fraction) + normal[tumor.contributions]*(normal.input) + tumor[tumor.contributions]*(tumor.input)

all.wbc.bins <- c((tail(tumor.contributions,n=1)+1):bins)
means.unaffected <- wbc[all.wbc.bins]
plasma.means <- c(means, means.unaffected)

y <- rpois(bins, plasma.means)

chunker <- function(x,n){
     split(x, cut(seq_along(x), n, labels = FALSE))
}

y.chunk <- chunker(y, groups)
wbc <- log(wbc)
normal <- log(normal)
tumor <- log(tumor)
wbc.chunk <- chunker(wbc, groups)
normal.chunk <- chunker(normal,groups)
tumor.chunk <- chunker(tumor, groups)

tf.blind <- numeric(groups)
z.total <- numeric(groups)
multiplied.mean <- numeric(groups)
cond.exp <- numeric(groups)

spotchecks <- sample(1:groups, 10, replace=FALSE)

for (iter in 1:groups){

    data <- list(y=y.chunk[[iter]], wbc=wbc.chunk[[iter]], normal=normal.chunk[[iter]], tumor=tumor.chunk[[iter]])
    fit <- jags.model("models/three_comp/with_z.jag",
                  data=data,
                  n.chains=1)
    
    samples <- coda.samples(fit, variable.names=c("b2", "z"),
                        n.iter=10000,
                        thin=10)

    samples <- ggs(samples)
    
    extract.z <- samples %>% filter(Parameter=="z") %>% select(value)
    extract.b2 <- samples %>% filter(Parameter=="b2") %>% select(value)

    multiplied.mean[iter] <- mean(extract.z$value*extract.b2$value)
    tf.blind[iter] <- mean(extract.b2$value)
    z.total[iter] <- mean(extract.z$value)
    tumor.derived <- which(extract.z$value==1)
    cond.exp[iter] <- mean(extract.b2$value[tumor.derived])

    if (iter %in% spotchecks){

        file <- paste0(directory,"/tf",iter,".pdf")
        out <- ggs_traceplot(samples) +
            ylim(c(0, 1))  +
            theme_bw() +
            ylab("") 
        ggsave(file, out,  width=10, height=10, units="in")
    }
}

true.tf <- (length(tumor.contributions)*tumor.fraction) / bins

print("start")
print(true.tf)
print(mean(multiplied.mean))
print("done")

res <- data.frame(tf.blind=tf.blind, z.total=z.total, multiplied.mean=multiplied.mean, cond.exp=cond.exp)
res[501,] <- c(mean(tf.blind), mean(z.total), mean(multiplied.mean), mean(cond.exp))

write.csv(res, paste0(directory,"/results.csv"), row.names=FALSE)

