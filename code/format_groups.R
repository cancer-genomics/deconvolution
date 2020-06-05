library(tidyverse)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/output_sim")
files <- list.files(full.names=TRUE, recursive=TRUE)

files <- files[grep("results.csv", files)]

estimates <- as.data.frame(matrix(0, nrow=length(files), ncol=5))

for (iter in 1:length(files)){
    x <- files[iter]

    #find true parameter values for simulation
    slash.idx <- as.data.frame(str_locate_all(x, "/")[[1]])$start
    name <- str_sub(x, slash.idx[1]+1, slash.idx[2]-1)

    underscore.idx <- as.data.frame(str_locate_all(name, "_")[[1]])$start
    group.fraction <- as.numeric(str_sub(name, underscore.idx[1]+1, underscore.idx[2]-1))
    tumor.fraction <- as.numeric(str_sub(name, underscore.idx[3]+1))

    true.tf <- group.fraction*tumor.fraction
    dat <- read_csv(x)
    dat$groups <- c(1:dim(dat)[1])
    tf.multiplied <- tail(dat$multiplied.mean,n=1)
    tf.blind <- tail(dat$tf.blind,n=1)

    num.groups <- (dim(dat)[1]) - 1
    tf.condexp <- dat$cond.exp[1:num.groups]
    tf.condexp[is.na(tf.condexp)] <- 0
    tf.condexp <- mean(tf.condexp)
    fin.z <- round(num.groups*group.fraction)

    estimates[iter, ] <- c(name, tf.condexp, tf.multiplied, tf.blind, true.tf)
    dat <- dat[1:num.groups,]

    zs <- ggplot(dat, aes(x=groups, y=z.total)) + geom_point() + theme_bw() + ylab("Post. Mean of Z") + geom_segment(aes(x=1,xend=fin.z,y=1,yend=1), color="red") + geom_segment(aes(x=fin.z+1,xend=num.groups,y=0,yend=0), color="blue")
    b2s <- ggplot(dat, aes(x=groups, y=multiplied.mean)) + geom_point() + theme_bw() + ylab("E[z*b2]") + geom_segment(aes(x=1,xend=fin.z,y=tumor.fraction,yend=tumor.fraction), color="red") + geom_segment(aes(x=fin.z + 1, xend=num.groups, y=0, yend=0), color="blue")
    
    plotfile <- paste0("plots/",name, ".pdf")
    pdf(plotfile)
    print(zs)
    print(b2s)
    dev.off()

}

colnames(estimates) <- c("id", "cond.exp", "E[b2*z]", "E[b2]", "Truth")
estimates$cond.exp <- NULL
estimates <- estimates %>% pivot_longer(-id, names_to="type",values_to="estimate")

compare <- ggplot(estimates, aes(fill=type, y=estimate, x=id)) + geom_bar(stat="identity", position="dodge") + theme_bw() + ylab("Tumor Fraction Estimate") + xlab("Simulation")

pdf("estimates.pdf")
compare
dev.off()

