deBias=function(x,svdObject){
  if(!inherits(x,"Incomplete"))x=as(x,"Incomplete")
  irow=x@i
  pcol=x@p
  x=x@x
  u=as.matrix(svdObject$u)
  v=as.matrix(svdObject$v)

  dd=dim(u)
  nnrow=as.integer(dd[1])
  nncol=as.integer(nrow(v))
  nrank=dd[2]
  storage.mode(u)="double"
  storage.mode(v)="double"
  storage.mode(irow)="integer"
  storage.mode(pcol)="integer"
  storage.mode(x)="double"
  nomega=as.integer(length(irow))
  out=.Fortran("plusregC",
           nnrow,nncol,nrank,u,v,irow,pcol,nomega,x,
           zy=double(nrank),zz=matrix(double(nrank*nrank),nrank,nrank),
           PACKAGE="softImpute"
           )
  zz=out$zz
  which=lower.tri(zz)
  zz[which]=t(zz)[which]
  zy=out$zy
  d=solve(zz,zy)
  sd=sign(d)
  if(any(sd<0)){
    d=abs(d)
    o=rev(order(d))
    v=scale(v,FALSE,sd)[,o]
    u=u[,o]
    d=d[o]
  }
  list(u=u,v=v,d=d)
}

