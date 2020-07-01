library(tidyverse)
library(quadprog)
library(Matrix)

path.to.maf <- "/dcl01/scharpf1/data/aarun/tumor_fractions.rds"
comparisons <- readRDS(path.to.maf)
comparisons$estimate <- NA

#can also do on 100 kb data
path <- "/dcl01/scharpf1/data/aarun/500kb_deconvolution.rds"

data <- readRDS(path)
data <- data %>% mutate(total= short.cor + long.cor)

if (grep("100",path==1){
	data$total[!is.finite(data$total)] <- 0
}

for (group.num in 1:20){
	test <- data %>% filter(group==group.num)
  
	plasma <- test %>% filter(sample=="plasma") %>% select(total)
	plasma <- as.matrix(plasma)
	buffy <- test %>% filter(sample=="buffy") %>% select(total)
	normal <- test %>% filter(sample=="normal") %>% select(total)
	
	if (dim(buffy)[1]==0||dim(normal)==0||dim(normal)[1]!=dim(buffy)[1]) {
		print("we are skipping a sample")
		next
	}
  
	standards <- as.matrix(cbind(buffy, normal))
	colnames(standards) <- c("buffy", "normal")
	if (rankMatrix(standards)==dim(standards)[2]){
  
			dvec <- t(standards) %*% plasma
			Dmat <- t(standards) %*% standards
			Amat <- as.matrix(data.frame(col1=c(1,1),col2=c(1,0),col3=c(0,1)))
			bvec <- as.matrix(data.frame(bvals=c(1,0,0)))
			meq <- 1

			scale <- norm(Dmat,"2")
			solution <- solve.QP(Dmat/scale, dvec/scale, Amat, bvec, meq, factorized=FALSE)
			comparisons$estimate[group.num] <- solution$solution[2]
	} else{
		print("standards matrix not full column rank")
		print(group.num)
	}
}
