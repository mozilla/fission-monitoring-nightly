dirch <- function(v, REP){
  res <- t(replicate(REP,{
    a <- sapply(v, function(s) rgamma(1,shape=s,scale=1))
    a/sum(a)
  }))
  return(res)
}

summarize.hist.cuts <- function(histo, REP=5000,CUT){
  getGTProb <- function(keys,probs,CUT){
    w <- keys >= CUT
    w1 <- keys < CUT
    l <- tail(probs[w1],1)
    l1 <- tail(keys[w1],1)
    r1 <- head(keys[w],1)
    ## some edge cases i havent thought of
    base.p <- sum(probs[w]) + (r1-CUT)/(r1-l1)*l
    return(base.p)
  }
  br <- histo[,{
    mean_estimates <- apply(dirch(psum,REP), 1, function(s){
      #mean(sample(key, 5000, replace=TRUE, prob = s) >= CUT)
      getGTProb(key,s, CUT)
    })
    stats <- c(avg   = mean(mean_estimates),
               lower = as.numeric(quantile(mean_estimates,0.05/2)),
               upper = as.numeric(quantile(mean_estimates,1-0.05/2)))
    data.table(nreporting=nreporting[1],
               low=stats[['lower']],
               est=stats[['avg']],
               high=stats[['upper']])
  } ,by=list(build_id=build_id,what=branch)][order(build_id, what),]
  
  rel <- histo[,{
    dis <- .SD[branch=='disabled',]
    ena <- .SD[branch=='enabled',]
    dis_mean_estimates <- apply(dirch(dis$psum,REP), 1, function(s){
      getGTProb(dis$key,s, CUT)
    })
    ena_mean_estimates <- apply(dirch(ena$psum,REP), 1, function(s){
      getGTProb(ena$key,s, CUT)
    })
    mean_estimates <- (ena_mean_estimates - dis_mean_estimates)/dis_mean_estimates*100
    stats <- c(avg   = mean(mean_estimates,na.rm=TRUE),
               lower = as.numeric(quantile(mean_estimates,0.05/2,na.rm=TRUE)),
               upper = as.numeric(quantile(mean_estimates,1-0.05/2,na.rm=TRUE)))
    data.table(what='reldiff(TvsC) %',nreporting=nreporting[1],
               low=stats[['lower']],
               est=stats[['avg']],
               high=stats[['upper']])
  } ,by=list(build_id=build_id)][order(build_id, what),]
  rbind(br,rel)[order(build_id,what),]
}

summarize.hist <- function (histo, REP = 500, sm = list(t= mean,i=function(s) s))
{
  br <- histo[, {
    D <- dirch(psum, REP)
    mean_estimates <- as.numeric(apply(D, 1, function(k) {
      sm$t(sample(key,10000, prob=k, replace=TRUE))
    }))
    stats <- c(avg = mean(sm$i(mean_estimates)),
               lower = sm$i(as.numeric(quantile(mean_estimates,0.05/2))),
               upper = sm$i(as.numeric(quantile(mean_estimates, 1-0.05/2))))
    data.table(nreporting = nreporting[1], 
               low = stats[["lower"]], est = stats[["avg"]], high = stats[["upper"]])
  }, by = list(build_id = build_id, what = branch)][order(build_id,
                                                        what), ]
  
  rel <- histo[, {
    dis <- .SD[branch=='disabled',]
    ena <- .SD[branch=='enabled',]
    Ddis <- dirch(dis$psum, REP)
    Dena <- dirch(ena$psum, REP)
    dis_mean_estimates <- as.numeric(apply(Ddis, 1, function(k) {
      sm$i(sm$t(mean(sample(dis$key,10000, prob=k, replace=TRUE))))
    }))
    ena_mean_estimates <- as.numeric(apply(Dena, 1, function(k) {
      sm$i(sm$t(mean(sample(ena$key,10000, prob=k, replace=TRUE))))
    }))
    mean_estimates <- (ena_mean_estimates - dis_mean_estimates)/dis_mean_estimates*100
    stats <- c(avg = mean(mean_estimates,na.rm=TRUE),
               lower = as.numeric(quantile(mean_estimates,0.05/2,na.rm=TRUE)),
               upper = as.numeric(quantile(mean_estimates, 1-0.05/2,na.rm=TRUE)))
    data.table(what='reldiff(TvsC) %',nreporting = nreporting[1],
               low = stats[["lower"]], est = stats[["avg"]], high = stats[["upper"]])
  }, by = list(build_id = build_id)][order(build_id, what), ]
  rbind(br,rel)[order(build_id,what),]
  
}
