library(tidyverse)
library(ggmcmc)

setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/models/results/exp_test")

#E[b2] E[b2|z=1] and traceplot of b2 for 12 permutations

df <- list.files(pattern = ".rds") %>% map_dfr(readRDS)

summaries <- df %>% group_by(id, Parameter) %>% summarize(avg=mean(value))

ids <- unique(df$id)
keep.ids <- ids[str_detect(ids, "wz")]

dat <- df %>% filter(id %in% keep.ids) %>% group_by(id) %>% group_split()

cond <- function(x){
    p <- x %>% filter(Parameter=="z")
    tumor.derived <- which(p$value==1)
    fin <- x %>% filter(Parameter=="b2") %>% filter(Iteration %in% tumor.derived)
    mean(fin$value)
}


conditional.expectations <- unlist(lapply(dat, cond))

r <- data.frame(id=unlist(lapply(dat, function(x) unique(x$id))), Parameter=rep("cond. exp", length(keep.ids)), avg=conditional.expectations)

summaries <- rbind(summaries, r)

saveRDS(summaries, "summary.rds")

#traceplots
plot <- function(x) {
    tib <- readRDS(x)
    main <- unique(tib$id)
    main <- unlist(str_split(main, "_"))
    main <- str_c(c("compartments: ", "TF: ", "Model: "), main)
    main <- paste0(main, collapse=", ")
    ggs_traceplot(tib) + ggtitle(main) + theme_bw()
}
files <- Sys.glob("*.rds")
traces <- lapply(files, plot)

pdf("traces.pdf")
traces
dev.off()

