REP <- 500
sm <- list(t= mean,i=function(s) s)

as.data.table(hist.df)[, {
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
    data.table(what='reldiff(TvsC) %',nreporting = nreporting[1])
               #low = stats[["lower"]], est = stats[["avg"]], high = stats[["upper"]])
  }, by = list(build_id = build_id)][order(build_id, what), ]



# con <- as.data.table(hist.df)[branch =='disabled',]
# Ddis <- dirch(con$psum, REP)
# dis_mean_estimates <- as.numeric(apply(Ddis, 1, function(k) {
#   sm$i(sm$t(mean(sample(con$key,10000, prob=k, replace=TRUE))))
# }))
# ena <- as.data.table(hist.df)[branch =='enabled',]
# Dena <- dirch(ena$psum, REP)
# ena_mean_estimates <- as.numeric(apply(Dena, 1, function(k) {
#   sm$i(sm$t(mean(sample(ena$key,10000, prob=k, replace=TRUE))))
# }))
