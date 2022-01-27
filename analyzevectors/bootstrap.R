
# by Dennis Toddenroth, 2022

.bootstrap.rows <- function(nrows) {
	training <- sample(seq(nrows),nrows,replace=T)
	trainingset <- data.frame(row=training,partition="TRAIN")
	evaluationset <- data.frame(row=setdiff(seq(nrows),training),
		partition="EVALUATION")
	rbind(trainingset,evaluationset)
}

bootstrap.partition <- function(x) {
	bootstrap.rows <- .bootstrap.rows(nrow(x))
	cbind(bootstrap.rows[,"partition",drop=F],x[bootstrap.rows$row,])
}

