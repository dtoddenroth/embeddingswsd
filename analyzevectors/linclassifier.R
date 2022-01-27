
# by Dennis Toddenroth, 2022

linclassifier <- function(x,y) { # x = vectors (numeric matrix), y = classes (binary)
	res <- list(inputdata=data.frame(x=x,y=y))
	res$gravity1 <- colMeans(x[y,])
	res$gravity2 <- colMeans(x[!y,])
	res$center <- with(res,(gravity1+gravity2)*.5)
	res$direction <- with(res,(gravity1-gravity2)*.5)
	structure(res,class="linclassifier")
}

predict.linclassifier <- function(x,newdata) with(x, {
	as.numeric(as.matrix(newdata-center) 
		%*% matrix(direction))/length(direction)
})


