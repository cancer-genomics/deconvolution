library(tidyverse)
library(rjags)
library(ggmcmc)
library(devtools)

load_all("deconvolution.data")
extdir <- system.file("extdata", package="deconvolution.data")
fname <- file.path(extdir, "500kb_deconvolution.rds")
dat <- readRDS(fname) %>%
    as_tibble() %>%
    rename(tissue_source=sample) %>%
    ## I'm guessing here
    mutate(bin=rep(seq_len(5008), 79))
##
## Most convenient format would be a matrix for each sample
## rows are bins, columns indicate tissue source
## - make for total coverage and short/long
##
id <- unique(dat$id)
J <- length(id)
rlist <- vector("list", length(id))
clist <- rlist
for(j in seq_len(J)){
    short <- filter(dat, id==id[j]) %>%
        select(tissue_source, bin, arm, short.cor) %>%
        spread(tissue_source, short.cor)
    shortm <- short %>%
        select(-c(bin, arm)) %>%
        as.matrix()
    long <- filter(dat, id==id[j]) %>%
        select(tissue_source, bin, arm, long.cor) %>%
        spread(tissue_source, long.cor)
    longm <- long %>%
        select(-c(bin, arm)) %>%
        as.matrix()
    ratios <- (shortm/longm) %>%
        as_tibble() %>%
        mutate(bin=short$bin,
               arm=short$arm)
    total <- (shortm + longm) %>%
        as_tibble() %>%
        mutate(bin=short$bin,
               arm=short$arm)
    rlist[[j]] <- ratios
    clist[[j]] <- total
}
names(rlist) <- names(clist) <- id

##
## First pass.  Start with sample with high maf
##
mafs <- readRDS(file.path(extdir, "tumor_fractions.rds")) %>%
    arrange(-ichor.tumor.fraction)
rlist <- rlist[mafs$id]
clist <- clist[mafs$id]
s1 <- clist[[1]]
dat <- list(y=s1$plasma,
            wbc=log(s1$buffy),
            tumor=log(s1$tumor),
            normal=(s1$normal))
fit <- jags.model("mixmodel.jag",
                  data=dat,
                  n.chains=3)
samples <- coda.samples(fit, variable.names="theta", n.iter=1000) %>%
    ggs()


