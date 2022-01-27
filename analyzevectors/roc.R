
# by Dennis Toddenroth, 2022

roc <- function(x,y) { # x = predictions (numeric), y = ground truth (binary)
	unique.x <- sort(unique(x))
	breaks <- .5*(c(-Inf,unique.x)+c(unique.x,Inf))
	res <- list(inputdata=data.frame(x=x,y=y))
	res$auc <- .5+mean(sign(outer(x[y>.5],x[!y>.5],"-")))*.5
	res$curve <- data.frame(do.call("rbind",lapply(breaks,function(b) 
		list(threshold=b,sens=mean(x[y>.5]>b),spec=mean(x[!y>.5]<b)))))
	structure(res,class="roc")
}

plot.roc <- function(res,add=F,col="red",...) {
	if (!add) {
		plot(0:1,0:1,type="n",xlim=1:0,ylim=0:1,axes=F,
			xlab="specificity",ylab="sensitivity")
		axis(1); axis(2)
	}
	with(res$curve,polygon(c(0,spec),c(0,sens),border=col,col=NA,...))
}

