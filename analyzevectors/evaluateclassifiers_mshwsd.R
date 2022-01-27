
library(RColorBrewer)
setwd("/home/dennis/work/nlp/analyzespacyvectors") 
source("analyzevectors/bootstrap.R") # bootstrap.partition(x)
source("analyzevectors/linclassifier.R") # linclassifier(x,y)
source("analyzevectors/roc.R") # roc(x,y)

modelcaptions <- c(sci_nostopwords="biomedical language model with stopword filtering",
	sci_withstopwords="biomedical language model without stopword filtering",
	web_nostopwords="general language model with stopword filtering",
	web_withstopwords="general language model without stopword filtering")

task.captions <- c(
	C0008778_C0015422="Cilia (organelle vs. eyelash)", 
	C0221971_C0018120="Follicle (hair vs. ovar)",
	C0324740_C0027960="Moles (insectivore vs. nevus)",
	C0333463_C0011389="Plaque (gray matter vs. teeth)")

vectorsets <- sapply(names(modelcaptions), function(modelname) 
	read.table(sprintf("vectorsets/mshwsd_%s.csv",modelname),h=T,sep=";"))

annotations <- read.table("mshwsd_annotations.csv",h=T,sep=";") # 924 rows

.extract.vectormatrix <- function(inputset) {
	vectorcolumns <- substr(colnames(inputset),0,3)=="vec"
	as.matrix(inputset[,vectorcolumns])
}

eval.model <- function(modelname) {
	inputset <- merge(annotations,vectorsets[[modelname]])
	bootstrapped.inputset <- bootstrap.partition(inputset)
	training.set <- subset(bootstrapped.inputset,partition=="TRAIN")[,-1]
	evaluation.set <- subset(bootstrapped.inputset,partition=="EVALUATION")[,-1]
	eval.task <- function(task.name) {
		training.subset <- subset(training.set,relation==task.name)
		evaluation.subset <- subset(evaluation.set,relation==task.name)
		x <- .extract.vectormatrix(training.subset)
		y <- training.subset$label=="M1"
		linmodel <- linclassifier(x,y)
		x <- .extract.vectormatrix(evaluation.subset)
		y <- evaluation.subset$label=="M1"
		roc(predict(linmodel,x),y)$auc
	}
	sapply(names(task.captions),eval.task)
}

n.bootstraps <- 200
set.seed(42)
result.matrix <- replicate(n.bootstraps,sapply(names(modelcaptions),eval.model))
result.data.frame <- do.call("rbind",
	lapply(1:n.bootstraps,function(i) 
		data.frame(result.matrix[,,i],task=rownames(result.matrix[,,i]))))
write.table(result.data.frame,"outputs/msh_wsd_auc_bootstrap.csv",sep=";",
	col.names=T,row.names=F)

taskcols <- structure(brewer.pal(4,"Set2"),names=levels(result.data.frame$task))

pdf("outputs/bootstrap_summary_mshwsd.pdf")
attach(result.data.frame)
boxplot(web_withstopwords~task,col=taskcols[task],at=.5+(1:4)*.2,
	xlim=c(0.5,4.5),ylim=c(.8,1),boxwex=.16,axes=F,xlab="",
	ylab="observed discrimination (area under the ROC curve)")
axis(2)
abline(h=1-(0:6)*.05,col="lightgray")

boxplot(web_withstopwords~task,col=taskcols[task],at=.5+(1:4)*.2,add=T,axes=F,boxwex=.16)
boxplot(web_nostopwords~task,col=taskcols[task],at=1.5+(1:4)*.2,add=T,axes=F,boxwex=.16)
boxplot(sci_withstopwords~task,col=taskcols[task],at=2.5+(1:4)*.2,add=T,axes=F,boxwex=.16)
boxplot(sci_nostopwords~task,col=taskcols[task],at=3.5+(1:4)*.2,add=T,axes=F,boxwex=.16)

title(sprintf("Performance of disambiguating MSH WSD homonyms\nwith linear classifiers trained in %s subsamples",n.bootstraps))
mtext(c("general language model","biomedical language model"),1,at=c(1.5,3.5),line=3)
mtext(c("with","without","with","without"),1,at=1:4,line=-.5)
mtext("stopwords",1,at=1:4,line=.5)

legend("bottomright",legend=task.captions[levels(task)],
	inset=.04,fill=taskcols,bg=adjustcolor("white",.8))

detach(result.data.frame)
dev.off()

with(result.data.frame,wilcox.test(c(web_withstopwords,web_nostopwords),
	c(sci_withstopwords,sci_nostopwords)))
with(result.data.frame,wilcox.test(c(sci_nostopwords,web_nostopwords),
	c(sci_withstopwords,web_withstopwords)))

