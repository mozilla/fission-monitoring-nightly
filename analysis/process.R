process_histograms <- function(probe, os=NULL) {
  hist.res <- tryCatch({
    print(paste(probe, ': ', os, sep=''))
    hist_query <-
      build_hist_query(probes.hist[[probe]], slug, tbl.main, min_build_id, os=os)
    hist <- bq_project_query(project_id, hist_query)
    hist.df <- bq_table_download(hist) %>%
      mutate(branch = case_when(
        branch == 'fission-enabled' ~ 'enabled',
        TRUE ~ 'disabled'
      )) %>%
      as.data.table()
    
    hist.summary <- summarize.hist(hist.df) %>%
      mutate(probe = probe) %>%
      rename(branch = what)
    list(raw = hist.df, summary = hist.summary)
  },
  error = function(err) {
    print(glue("ERROR processsing {probe}: {err}"))
    return(c(raw = NULL, summary = NULL))
  })
  return(hist.res) 
}

process_histograms_95th <- function(probe, os=NULL) {
  hist.res <- tryCatch({
    print(probe)
    hist_query <-
      build_hist_query(probes.hist.perc.95[[probe]], slug, tbl.main, min_build_id, os=os)
    hist <- bq_project_query(project_id, hist_query)
    hist.df <- bq_table_download(hist) %>%
      mutate(branch = case_when(
        branch == 'fission-enabled' ~ 'enabled',
        TRUE ~ 'disabled'
      )) %>%
      as.data.table()
    
    hist.summary.95th <- summarize.hist.perc(hist.df, 0.95) %>%
      mutate(probe = probe) %>%
      rename(branch = what)
    list(raw = hist.df, summary = hist.summary.95th)
  },
  error = function(err) {
    print(glue("ERROR processsing {probe}: {err}"))
    return(c(raw = NULL, summary = NULL))
  })
  return(hist.res) 
}

process_scalar <- function(df, probe, perc.high, bs_replicates) {
  scalar.res <- tryCatch({
    df[get(probe) < quantile(get(probe), perc.high, na.rm = TRUE),
              summarize.scalar(.SD[, list(id, branch, x =
                                            get(probe))], "x", bs_replicates, stat = mean.narm),
              by = build_id][, probe := probe][order(build_id, what),] %>%
      rename(branch = what)
  },
  error = function(err) {
    print(glue("ERROR processsing {probe}: {err}"))
    return(NULL)
  })
  return(scalar.res)
}

process_crash <- function(df, probe, perc.high, bs_replicates, stat=mean.narm, name = probe) {
  crashes.res <- tryCatch({
    print(probe)
    df[get(probe) < quantile(get(probe), perc.high, na.rm = TRUE),
               summarize.scalar(.SD[, list(id, branch, x =
                                             get(probe))], "x",
                                bs_replicates, stat = stat),
               by = build_id][, probe := probe][order(build_id, what), ] %>%
      rename(branch = what) %>%
      mutate(probe = name)
  },
  error = function(err) {
    print(glue("ERROR processsing {probe}: {err}"))
    return(NULL)
  })
  return(crashes.res)
}

calc_crash_stats <- function(crashes.df, crashes.ui=NULL){
  results.crashes <- list()
  
  # Crashes per hour
  for (probe in names(probes.crashes)) {
    probe_per_hour <- paste(probe, '_PER_HOUR', sep = '')
    results.crashes[[probe_per_hour]] <- process_crash(crashes.df, probe_per_hour, perc.high, bs_replicates)
    if (is.debug)
      break
  }
  
  if (!is.null(crashes.ui)){
    for (probe in names(probes.crashes.ui)) {
      probe_per_hour <- paste(probe, '_PER_HOUR', sep = '')
      results.crashes[[probe_per_hour]] <- process_crash(crashes.ui, probe_per_hour, perc.high, bs_replicates)
      if (is.debug)
        break
    }
  }
  
  # Distinct crashing client count
  client_count.stat <- function(x) length(which(!is.na(x) & x>0))
  
  for (probe in names(probes.crashes)) {
    probe_client_count <- paste(probe, '_CLIENT_COUNT', sep = '')
    results.crashes[[probe_client_count]] <- process_crash(crashes.df,
                                                           probe, 
                                                           perc.high,
                                                           bs_replicates,
                                                           stat = client_count.stat,
                                                           name = probe_client_count)
    if (is.debug)
      break
  }
  
  if (!is.null(crashes.ui)){
    for (probe in names(probes.crashes.ui)) {
      probe_client_count <- paste(probe, '_CLIENT_COUNT', sep = '')
      results.crashes[[probe_client_count]] <- process_crash(crashes.ui,
                                                             probe, 
                                                             perc.high,
                                                             bs_replicates,
                                                             stat = client_count.stat,
                                                             name = probe_client_count)
      if (is.debug)
        break
      
    } 
  }
  return(results.crashes)
}
