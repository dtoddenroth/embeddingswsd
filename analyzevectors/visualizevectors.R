
library(RColorBrewer)
setwd("/home/dennis/work/nlp/analyzespacyvectors") 
source("analyzevectors/bicolorarrows.R") # bicolor.arrow(from,to,sourcecol,targetcol)
source("analyzevectors/config.R") # cols, modelcaptions, class.labels

annotations <- read.table("annotations.csv",h=T,sep=";")
# limit analysis to 1493 abstracts with unique labels and available vectors: 
annotations <- subset(annotations,
	!pubmedid %in% with(annotations,pubmedid[duplicated(pubmedid)]))
# reorder labels as color-consistent pairs
annotations[,1] <- factor(annotations[,1],levels=class.labels)

draw.pca <- function(inputset,caption) {
	vectorcolumns <- substr(colnames(inputset),0,3)=="vec"
	inputset.vectormatrix <- as.matrix(inputset[,vectorcolumns])
	pca <- prcomp(inputset.vectormatrix)
	plot(pca$x[,1:2],col=cols[as.numeric(inputset$label)],lwd=3,cex=1.6,
		pch=ifelse(is.lang(as.character(inputset$label)),4,1),axes=F,
		xlab=sprintf("first of %s projected vector dimensions",ncol(pca$x)),
		ylab=sprintf("second of %s projected vector dimensions",ncol(pca$x)))
	
	gravity.centers <- do.call("rbind",by(inputset.vectormatrix,
		inputset$label,colMeans))
	projected.gravity.centers <- predict(pca,gravity.centers)[,1:2]
	
	bicolor.arrow(projected.gravity.centers[2,],
		projected.gravity.centers[1,],cols[2],cols[1])
	bicolor.arrow(projected.gravity.centers[4,],
		projected.gravity.centers[3,],cols[4],cols[3])
	bicolor.arrow(projected.gravity.centers[6,],
		projected.gravity.centers[5,],cols[6],cols[5])
	bicolor.arrow(projected.gravity.centers[8,],
		projected.gravity.centers[7,],cols[8],cols[7])
	
	labelfreqs <- table(inputset$label)
	captions <- sprintf("%sx %s",labelfreqs[class.labels],c(languages,homonyms)[class.labels])
	legend("topleft",legend=captions,col=cols,pt.cex=1.6,
		pch=ifelse(is.lang(class.labels),4,1),pt.lwd=3,
		bg=adjustcolor("white",.8))
	title(sprintf("Principal Component Analysis of %s abstract-specific vectors:\n%s",
		nrow(inputset.vectormatrix),caption))
}

pdf("outputs/pca.pdf")
for (modelname in names(modelcaptions)) {
	vectorfile <- sprintf("vectorsets/vectors_%s.csv",modelname)
	vectors <- read.table(vectorfile,h=T,sep=";")
	draw.pca(merge(annotations,vectors),modelcaptions[modelname])
}
dev.off()

