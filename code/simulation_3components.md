---
title: "Three-component deconvolution model"
date: "2020-06-09"
output:	
  html_document:
    keep_md: true
---



```r
library(tidyverse)
library(ggmcmc)
library(rjags)
library(fs)
outdir <- file.path("..", "output", "simulation_3components.Rmd")
dir_create(outdir)
```

Simulate fragment-level coverage for buffy coat (wbc), normal tissue (normal), andtumor tissue.


```r
##setwd("/dcl01/scharpf1/data/aarun/deconvolution/code/models")
lambdas <- c(300, 400, 500)
nbins <- 1000
wbc <- rpois(nbins, lambdas[1])
normal <- rpois(nbins, lambdas[2])
tumor <- rpois(nbins, lambdas[3])
tf.nf <- c(0.05, 0.1)
p <- c(tf.nf, 1-sum(tf.nf))
##
## Assumes same normal/tumor/wbc contribution across all bins
##
plasma_means <- p[1]*normal + p[2]*tumor + p[3]*wbc
plasma <- rpois(n, plasma_means)
dat <- tibble(y=plasma,
              wbc=wbc,
              normal=normal,
              tumor=tumor,
              mixture=plasma_means)
```


```r
ggplot(dat, aes(mixture, y)) +
    geom_point() +
    xlab(expression("p[1]N+p[2]T+p[3]W")) +
    geom_smooth(method=lm, se=FALSE) +
    xlim(c(200, 400)) +
    ylim(c(200, 400))
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 3 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 3 rows containing missing values (geom_point).
```

![](simulation_3components_files/figure-html/plot_simulation-1.png)<!-- -->

# MCMC


```r
jags_data <- dat %>%
    select(-mixture) %>%
    as.list()
model <- file.path("models", "three_comp", "simple.jag")
fit <- jags.model(model, data=jags_data, n.chains=1)
samples <- coda.samples(fit,
                        variable.names="p", 
                        n.iter=500*1000, thin=500)
```

# Post-hoc diagnostics


```r
## Would like this to be near 1000
coda::effectiveSize(samples)
```

```
##     p[1]     p[2]     p[3] 
## 443.4470 453.2246 472.6542
```

```r
chains <- ggs(samples)
truth <- tibble(p=p, Parameter=levels(chains$Parameter))
chains %>%
    ggs_traceplot() +
    geom_hline(data=truth, aes(yintercept=p))
```

![](simulation_3components_files/figure-html/diagnostics-1.png)<!-- -->



# Session info


```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                                   
##  version  R version 4.0.0 beta (2020-04-15 r78231)
##  os       macOS Catalina 10.15.5                  
##  system   x86_64, darwin19.4.0                    
##  ui       X11                                     
##  language (EN)                                    
##  collate  en_US.UTF-8                             
##  ctype    en_US.UTF-8                             
##  tz       America/New_York                        
##  date     2020-06-09                              
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version date       lib source        
##  assertthat     0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  backports      1.1.7   2020-05-13 [1] CRAN (R 4.0.0)
##  blob           1.2.1   2020-01-20 [1] CRAN (R 4.0.0)
##  broom          0.5.6   2020-04-20 [1] CRAN (R 4.0.0)
##  callr          3.4.3   2020-03-28 [1] CRAN (R 4.0.0)
##  cellranger     1.1.0   2016-07-27 [1] CRAN (R 4.0.0)
##  cli            2.0.2   2020-02-28 [1] CRAN (R 4.0.0)
##  coda         * 0.19-3  2019-07-05 [1] CRAN (R 4.0.0)
##  codetools      0.2-16  2018-12-24 [2] CRAN (R 4.0.0)
##  colorspace     1.4-1   2019-03-18 [1] CRAN (R 4.0.0)
##  crayon         1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  DBI            1.1.0   2019-12-15 [1] CRAN (R 4.0.0)
##  dbplyr         1.4.4   2020-05-27 [1] CRAN (R 4.0.0)
##  desc           1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools       2.3.0   2020-04-10 [1] CRAN (R 4.0.0)
##  digest         0.6.25  2020-02-23 [1] CRAN (R 4.0.0)
##  dplyr        * 1.0.0   2020-05-29 [1] CRAN (R 4.0.0)
##  ellipsis       0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate       0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi          0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  farver         2.0.3   2020-01-16 [1] CRAN (R 4.0.0)
##  forcats      * 0.5.0   2020-03-01 [1] CRAN (R 4.0.0)
##  fs           * 1.4.1   2020-04-04 [1] CRAN (R 4.0.0)
##  generics       0.0.2   2018-11-29 [1] CRAN (R 4.0.0)
##  GGally         1.5.0   2020-03-25 [1] CRAN (R 4.0.0)
##  ggmcmc       * 1.4.1   2020-04-02 [1] CRAN (R 4.0.0)
##  ggplot2      * 3.3.1   2020-05-28 [1] CRAN (R 4.0.0)
##  glue           1.4.1   2020-05-13 [1] CRAN (R 4.0.0)
##  gtable         0.3.0   2019-03-25 [1] CRAN (R 4.0.0)
##  haven          2.3.1   2020-06-01 [1] CRAN (R 4.0.0)
##  hms            0.5.3   2020-01-08 [1] CRAN (R 4.0.0)
##  htmltools      0.4.0   2019-10-04 [1] CRAN (R 4.0.0)
##  httr           1.4.1   2019-08-05 [1] CRAN (R 4.0.0)
##  jsonlite       1.6.1   2020-02-02 [1] CRAN (R 4.0.0)
##  knitr          1.28    2020-02-06 [1] CRAN (R 4.0.0)
##  labeling       0.3     2014-08-23 [1] CRAN (R 4.0.0)
##  lattice        0.20-41 2020-04-02 [2] CRAN (R 4.0.0)
##  lifecycle      0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  lubridate      1.7.8   2020-04-06 [1] CRAN (R 4.0.0)
##  magrittr       1.5     2014-11-22 [1] CRAN (R 4.0.0)
##  Matrix         1.2-18  2019-11-27 [2] CRAN (R 4.0.0)
##  memoise        1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  mgcv           1.8-31  2019-11-09 [2] CRAN (R 4.0.0)
##  modelr         0.1.8   2020-05-19 [1] CRAN (R 4.0.0)
##  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.0.0)
##  nlme           3.1-148 2020-05-24 [2] CRAN (R 4.0.0)
##  pillar         1.4.4   2020-05-05 [1] CRAN (R 4.0.0)
##  pkgbuild       1.0.8   2020-05-07 [1] CRAN (R 4.0.0)
##  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.0.0)
##  pkgload        1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  plyr           1.8.6   2020-03-03 [1] CRAN (R 4.0.0)
##  prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx       3.4.2   2020-02-09 [1] CRAN (R 4.0.0)
##  ps             1.3.3   2020-05-08 [1] CRAN (R 4.0.0)
##  purrr        * 0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6             2.4.1   2019-11-12 [1] CRAN (R 4.0.0)
##  RColorBrewer   1.1-2   2014-12-07 [1] CRAN (R 4.0.0)
##  Rcpp           1.0.4.6 2020-04-09 [1] CRAN (R 4.0.0)
##  readr        * 1.3.1   2018-12-21 [1] CRAN (R 4.0.0)
##  readxl         1.3.1   2019-03-13 [1] CRAN (R 4.0.0)
##  remotes        2.1.1   2020-02-15 [1] CRAN (R 4.0.0)
##  reprex         0.3.0   2019-05-16 [1] CRAN (R 4.0.0)
##  reshape        0.8.8   2018-10-23 [1] CRAN (R 4.0.0)
##  rjags        * 4-10    2019-11-06 [1] CRAN (R 4.0.0)
##  rlang          0.4.6   2020-05-02 [1] CRAN (R 4.0.0)
##  rmarkdown      2.2     2020-05-31 [1] CRAN (R 4.0.0)
##  rprojroot      1.3-2   2018-01-03 [1] CRAN (R 4.0.0)
##  rstudioapi     0.11    2020-02-07 [1] CRAN (R 4.0.0)
##  rvest          0.3.5   2019-11-08 [1] CRAN (R 4.0.0)
##  scales         1.1.1   2020-05-11 [1] CRAN (R 4.0.0)
##  sessioninfo    1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi        1.4.6   2020-02-17 [1] CRAN (R 4.0.0)
##  stringr      * 1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat       2.3.2   2020-03-02 [1] CRAN (R 4.0.0)
##  tibble       * 3.0.1   2020-04-20 [1] CRAN (R 4.0.0)
##  tidyr        * 1.1.0   2020-05-20 [1] CRAN (R 4.0.0)
##  tidyselect     1.1.0   2020-05-11 [1] CRAN (R 4.0.0)
##  tidyverse    * 1.3.0   2019-11-21 [1] CRAN (R 4.0.0)
##  usethis        1.6.1   2020-04-29 [1] CRAN (R 4.0.0)
##  utf8           1.1.4   2018-05-24 [1] CRAN (R 4.0.0)
##  vctrs          0.3.0   2020-05-11 [1] CRAN (R 4.0.0)
##  withr          2.2.0   2020-04-20 [1] CRAN (R 4.0.0)
##  xfun           0.14    2020-05-20 [1] CRAN (R 4.0.0)
##  xml2           1.3.2   2020-04-23 [1] CRAN (R 4.0.0)
##  yaml           2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Users/rscharpf/Library/R/3.11-bioc-release
## [2] /Users/rscharpf/Rversions/R-4.0.0/library
```
