hist.data.frame <- function(x, n.unique=3, nclass="compute", na.big=FALSE,
							rugs=FALSE, mtitl=FALSE, ...) {
  oldmf  <- par('mfrow')
  oldoma <- par('oma')
  on.exit(par(mfrow=oldmf, oma=oldoma))
  mf <- oldmf
  if(length(mf)==0) mf <- c(1,1)
  automf <- FALSE  ## 22sep02
  if((la <- length(x))>1 & max(mf)==1) {
    mf <- if(la<=4)c(2,2) else if(la<=6)c(2,3) else if(la<=9)c(3,3) else
	if(la<=12)c(3,4) else if(la<=16) c(4,4) else c(4,5)
    automf <- TRUE
    par(mfrow=mf)
  }
  if(is.character(mtitl)) par(oma=c(0,0,3,0))
  nam <- names(x)
  i <- 0
  j <- 0
  for(v in x) {
	j <- j+1
	if(!is.character(v)) {
      type <- if(inherits(v,'factor'))'factor' else
      if(inherits(v,'dates'))'date' else 'none'
      if(type!='none') v <- oldUnclass(v)
      w <- v[!is.na(v)]
      n <- length(w)
      if(length(unique(w)) >= n.unique) {
        i <- i+1
        if(is.numeric(nclass)) nc <- nclass else
        if(nclass=="compute") nc <- max(2,trunc(min(n/10,25*logb(n,10))/2))
        lab <- attr(v,"label")
        lab <- if(length(lab) && nchar(lab) > 35) nam[j] else
        label(v, units=TRUE, plot=TRUE, default=nam[j])
        ##	nl <- if(is.null(lab)) 0 else nchar(lab)  26sep02
        ##	if(nl==0 | nl>20)lab <- nam[j]
        if(.R.) {
          if(nclass!="default")hist(v,nclass=nc,xlab=lab,
               axes=type!='date',main='')
          else hist(v,xlab=lab, axes=type!='date',main='')
        } else {
          if(nclass!="default")hist(v,nclass=nc,xlab=lab,style.bar='old',
               axes=type!='date')
          else hist(v,xlab=lab,style.bar='old', axes=type!='date')
        }
        if(type=='date') {
          axis(2)
          r <- range(v, na.rm=TRUE)
          by <- round((r[2]-r[1])/(par('lab')[2] - 1))
          at <- seq(r[1], r[2], by=by)
          axis(1, at=at, labels=format(chron(at)))
        }
      
        m <- sum(is.na(v))
        pm <- paste("n:",n," m:",m,sep="")
        title(sub=pm,adj=0,cex=.5)
        if(na.big && m>0) mtext(paste(m,"NAs"),line=-2,cex=1)
        if(rugs) scat1d(v, ...)
        if(automf && interactive() && names(dev.list())!='postscript' &&
           (i %% prod(mf)==0))	{
          if(is.character(mtitl)) mtitle(mtitl)
          cat("click left mouse button to proceed\n")
          locator(1)
        } else if(is.character(mtitl) && i %% prod(mf)==1) mtitle(mtitl)
      }
    }
  }
  invisible(ceiling(i / prod(mf)))
}