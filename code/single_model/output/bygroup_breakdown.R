library(tidyverse)
setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/single_model/output")
#leading model, i.e. model we want to look at 
model <- "nlog_int"

#we are also interested in the no_z case
noz.model <- paste0("no_z/",model)

files.z <- list.files(model, full.names=TRUE)
files.noz <- list.files(noz.model, full.names=TRUE)

n.groups <- 500

bias.noz <- function(x){
    dat <- readRDS(x)
    dat <- dat %>% group_by(Parameter) %>% summarize(estimate.tf=mean(value))
    groups.w.tumor <- as.numeric(str_sub(x, -11, -9))
    tumor.fraction <- as.numeric(str_sub(x, -7, -5))
    dat$true.tf <- 0
    dat$true.tf[1:(n.groups*groups.w.tumor)] <- tumor.fraction
    dat$Parameter <- c(1: (dim(dat)[1]))
    dat <- dat %>% pivot_longer(-Parameter, names_to="type", values_to="tumor.fraction")
    colnames(dat)[1] <- "group"

    out <- ggplot(dat, aes(x=group, y=tumor.fraction, color=type)) + geom_point() + ggtitle(paste0("no Z, groups.w.tumor: ", groups.w.tumor, ", tumor.frac for those groups: ", tumor.fraction))
    out
}   

noz.plots <- lapply(files.noz, bias.noz)

bias.z <- function(x){
    dat <- readRDS(x)
param.values <- unique(dat$Parameter)
keep.b2 <- grep("b2",param.values)
keep.z <- grep("z",param.values)
keep.b2 <- param.values[keep.b2]
keep.z <- param.values[keep.z]

extract.z <- dat %>% filter(Parameter %in% keep.z) %>% select(value)
extract.b2 <- dat %>% filter(Parameter %in% keep.b2) %>% select(value)

answer <- extract.z$value*extract.b2$value

grouplength <- (dim(dat)[1]/3) / n.groups

dat <- as_tibble(data.frame(estimate.tf=answer, group=rep(1:n.groups, each=grouplength)))
groups.w.tumor <- as.numeric(str_sub(x, -11, -9))
    tumor.fraction <- as.numeric(str_sub(x, -7, -5))
    dat$true.tf <- 0
    dat$true.tf[1:(n.groups*groups.w.tumor)] <- tumor.fraction
    dat <- dat %>% pivot_longer(-group, names_to="type", values_to="tumor.fraction")

    out <- ggplot(dat, aes(x=group, y=tumor.fraction, color=type)) + geom_point() + ggtitle(paste0("Z, groups.w.tumor: ", groups.w.tumor, ", tumor.frac for those groups: ", tumor.fraction))
    out
}

z.plots <- lapply(files.z, bias.z)

pdf("pergroup_performance.pdf")
noz.plots
z.plots
dev.off()


