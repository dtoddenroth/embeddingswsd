
library(RColorBrewer)
setwd("/home/dennis/work/nlp/analyzespacyvectors") 
source("analyzevectors/bootstrap.R") # bootstrap.partition(x)
source("analyzevectors/linclassifier.R") # linclassifier(x,y)
source("analyzevectors/roc.R") # roc(x,y)
source("analyzevectors/config.R") # cols, modelcaptions, class.labels, languages, homonyms

annotations <- read.table("annotations.csv",h=T,sep=";")
# limit analysis to 1493 abstracts with unique labels and available vectors: 
annotations <- subset(annotations,
	!pubmedid %in% with(annotations,pubmedid[duplicated(pubmedid)]))
# reorder labels as color-consistent pairs
annotations[,1] <- factor(annotations[,1],levels=class.labels)

.extract.vectormatrix <- function(inputset) {
	vectorcolumns <- substr(colnames(inputset),0,3)=="vec"
	as.matrix(inputset[,vectorcolumns])
}

eval.model <- function(modelname,draw.plot=T) {
	vectorfile <- sprintf("vectorsets/vectors_%s.csv",modelname)
	vectors <- read.table(vectorfile,h=T,sep=";")
	inputset <- merge(annotations,vectors)
	bootstrapped.inputset <- bootstrap.partition(inputset)
	training.set <- subset(bootstrapped.inputset,partition=="TRAIN")[,-1]
	evaluation.set <- subset(bootstrapped.inputset,partition=="EVALUATION")[,-1]
	eval.task <- function(task.index) {
		label.subsets <- class.labels[(2*task.index)+(-1:0)]
		col.lang <- cols[(2*task.index)-1]
		training.subset <- subset(training.set,label %in% label.subsets)
		x <- .extract.vectormatrix(training.subset)
		y <- training.subset$label==label.subsets[1]
		linmodel <- linclassifier(x,y)

		evaluation.subset <- subset(evaluation.set,label %in% label.subsets)
		x <- .extract.vectormatrix(evaluation.subset)
		y <- evaluation.subset$label==label.subsets[1]
		preds <- predict(linmodel,x)
		task.roc <- roc(preds,y)
		if (draw.plot)
			plot(task.roc,add=task.index>1,col=col.lang,lwd=4)
		task.roc$auc
	}
	task.aucs <- sapply(seq(4),eval.task)
	if (draw.plot) {
		segments(0,1,1,0,lty=2)
		legend("bottomright",
			legend=sprintf("%s vs. %s (AUC %.3f)",languages,homonyms,task.aucs),
			inset=.04,col=cols[c(1,3,5,7)],lwd=4,bg=adjustcolor("white",.8))
		title(sprintf("Performance of binary classifiers with\n%s",modelcaptions[modelname]))
	}
	names(task.aucs) <- paste(class.labels[2*(1:4)-1],class.labels[2*(1:4)],sep=".")
	task.aucs
}

pdf("outputs/rocs.pdf")
for (modelname in names(modelcaptions)) {
	set.seed(42)
	aucs <- eval.model(modelname)
}
dev.off()

n.bootstraps <- 200
set.seed(42)
result.matrix <- replicate(n.bootstraps,sapply(names(modelcaptions),eval.model,draw.plot=F))
result.data.frame <- do.call("rbind",
	lapply(1:n.bootstraps,function(i) 
		data.frame(result.matrix[,,i],task=rownames(result.matrix[,,i]))))
write.table(result.data.frame,"outputs/auc_bootstrap.csv",sep=";",
	col.names=T,row.names=F)

taskcols <- structure(cols[(1:4)*2],names=levels(result.data.frame$task))

pdf("outputs/bootstrap_summary.pdf")
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

title(sprintf("Performance of disambiguating technical homonyms\nwith linear classifiers trained in %s subsamples",n.bootstraps))
mtext(c("general language model","biomedical language model"),1,at=c(1.5,3.5),line=3)
mtext(c("with","without","with","without"),1,at=1:4,line=-.5)
mtext("stopwords",1,at=1:4,line=.5)

legend("bottomright",legend=sprintf("%s vs. %s",languages,homonyms),
	inset=.04,fill=taskcols,bg=adjustcolor("white",.8))

detach(result.data.frame)
dev.off()

with(result.data.frame,wilcox.test(c(web_withstopwords,web_nostopwords),
	c(sci_withstopwords,sci_nostopwords)))
with(result.data.frame,wilcox.test(c(sci_nostopwords,web_nostopwords),
	c(sci_withstopwords,web_withstopwords)))

