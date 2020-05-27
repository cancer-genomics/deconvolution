library(tidyverse)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/output_sim")

wbc <- read.table("wbc_estimates.txt")$V1
z <- read.table("z_estimates.txt")$V1
n <- length(z)
dat <- data.frame(group=1:n, z=z, wbc=wbc) %>% as_tibble()

tumor.fraction.estimate <- 1 - mean(wbc)

groups.w.tumor.contribution <- 50
TPR <- dat %>% filter(group <= groups.w.tumor.contribution) %>% summarise(tot=sum(z) / groups.w.tumor.contribution) 
FPR <- dat %>% filter(group > groups.w.tumor.contribution) %>% summarise(tot= sum(z) / ((tail(group, 1)) - groups.w.tumor.contribution) ) 

z.vis <- ggplot(dat, aes(x=group, y=z)) + geom_vline(xintercept=100, color="Red") + ylim(c(0,1)) + theme_bw() + ylab("Latent Z Variable") + xlab("Group #") + geom_point()
wbc.vis <- ggplot(dat, aes(x=group, y=wbc)) + geom_hline(yintercept=mean(wbc), color="blue") +geom_point() + ylim(c(0.75,1)) + theme_bw() + ylab("WBC Fraction") + xlab("Group")

pdf("parameters.pdf")
z.vis
wbc.vis
dev.off()
