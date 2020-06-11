library(tidyverse)
library(pracma)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/single_model/output/no_z")

files <- list.files(recursive=TRUE, pattern=".rds")

#region under which we consider the tumor fraction to be 0

rocR <- function(j){
results <- readRDS(j)
equivalence_region <- 0.03
dat <- results %>% group_by(Parameter) %>% summarize(frac=sum(value > equivalence_region)/n())

nonzero.tf.groups <- as.numeric(str_sub(j, -11, -9))

n <- length(dat$frac)
t.len <- n - (n*nonzero.tf.groups)
f.len <- n - t.len

dat$truth <- c(rep("TRUE", t.len), rep("FALSE", f.len))

dat <- dat %>% arrange(desc(frac))

dat$truth <- as.logical(dat$truth)

dat$tp <- cumsum(dat$truth) / t.len

dat$spec <- (f.len - cumsum(!dat$truth)) / f.len

dat$fp <- 1 - dat$spec
auc <- round(trapz(dat$fp, dat$tp), 3)
roc <- ggplot(dat, aes(x=fp, y=tp)) + geom_line() + theme_bw() + xlab("1 - Specificity") + ylab("Sensitivity") + ggtitle(paste0(j, ", AUC: ", auc))
roc
#temp <- paste0(str_sub(j, 1, -5),".pdf")
#ggsave(temp, roc)
}

t <- lapply(files, function(j) rocR(j))

pdf("plots.pdf")
t
dev.off()


