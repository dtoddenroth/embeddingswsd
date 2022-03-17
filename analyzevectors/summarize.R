
# setwd("repository/outputs")
aucs1 <- read.table("auc_bootstrap.csv",h=T,sep=";")
aucs2 <- read.table("msh_wsd_auc_bootstrap.csv",h=T,sep=";")
overall.results <- rbind(aucs1,aucs2)
(medians <- apply(overall.results[,-5],2,median))
(percentage.differences <- round(100*outer(medians,medians,"-"),1))
(summaries <- apply(overall.results[,-5],2,fivenum))
round(summaries,3)

readable.summary <- function(x,digits=3,fmt="median %s (IQR %s - %s)") {
	params <- c(fmt=fmt,round(quantile(x,c(.5,.25,.75)),digits))
	do.call(sprintf,as.list(params))
}

apply(overall.results[,-5],2,readable.summary)

