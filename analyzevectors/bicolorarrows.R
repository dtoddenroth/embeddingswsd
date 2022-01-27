
# by Dennis Toddenroth, 2022

bicolor.arrow <- function(from,to,sourcecol,targetcol,
	lwd=6,bg=adjustcolor("black",.9)) {
	midpoint <- c((from[1]+to[1])*.5,(from[2]+to[2])*.5)
	points(from[1],from[2],cex=3,pch=1,lwd=lwd+4,col=bg)
	points(to[1],to[2],cex=3,pch=4,lwd=lwd+4,col=bg)
	points(from[1],from[2],cex=3,pch=1,lwd=lwd+2,col=sourcecol)
	points(to[1],to[2],cex=3,pch=4,lwd=lwd+2,col=targetcol)
	arrows(from[1],from[2],to[1],to[2],.4,lwd=lwd+4,col=bg)
	lines(rbind(from,midpoint),lwd=lwd+2,col=sourcecol)
	arrows(midpoint[1],midpoint[2],to[1],to[2],.4,lwd=lwd+2,col=targetcol)
}

