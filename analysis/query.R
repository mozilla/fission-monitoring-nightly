library(glue)
source('query_strings.R')

#### Query Helpers ####
build_crash_table <- function(min_build_id, min_build_date){
  return(glue(crash_create_base,
              min_build_id = min_build_id,
              min_build_date = min_build_date))
}

build_main_query <- function(probes.hist, slug, tbl){ 
  query_hist = dplyr::case_when(
    !is.null(probes.hist) ~ paste('  ', 'mozfun.hist.extract(', unlist(probes.hist), ").values", ' AS ', names(probes.hist), sep = '', collapse = ',\n'),
    TRUE ~ ''
  )
  main_query = glue(main_query_base,
                    query_hist = query_hist,
                    slug = slug,
                    tbl = tbl
  )
  return(main_query)
}

build_hist_query <- function(probe.hist, slug, tbl, min_build_id,  min_build_date, os, hist_query_base. = hist_query_base){
  additional_filters <- dplyr::case_when(
    !is.null(os) ~ paste("AND normalized_os = '", os,"'", sep='') ,
    TRUE ~ '')
  return(glue(hist_query_base., 
              probe_hist = probe.hist,
              tbl = tbl,
              min_build_id = min_build_id,
              slug = slug,
              additional_filters = additional_filters
  )
  )
}

build_crash_query <- function(probes.crashes, slug, tbl, min_build_id, os=NULL, crashes_query_base. = crashes_query_base){
  query_crashes <- paste('  ', 'SUM(', unlist(probes.crashes), ') AS ', names(probes.crashes), sep = '', collapse = ',\n') 
  query_crashes_per_hour <- paste('  SAFE_DIVIDE(', names(probes.crashes), ', USAGE_HOURS)', ' AS ', names(probes.crashes), '_PER_HOUR', sep='', collapse=',\n')
  additional_filters <- dplyr::case_when(
    !is.null(os) ~ paste("AND os_name = '", os,"'", sep='') ,
    TRUE ~ '')
  return(glue(crashes_query_base.,
              tbl = tbl,
              query_crashes = query_crashes,
              query_crashes_probes = paste('  ', names(probes.crashes), collapse=',\n'),
              query_crashes_per_hour = query_crashes_per_hour,
              min_build_id = min_build_id,
              additional_filters = additional_filters
  ))
}


# TODO: Add in min_build_date arg for consistency
build_crash_ui_query <- function(probes.crashes, slug, tbl, min_build_id, os=NULL, crashes_query_base. = crashes_ui_query_base){
  query_crashes <- paste('  ', 'SUM(COALESCE(', unlist(probes.crashes), ',0)) AS ', names(probes.crashes), sep = '', collapse = ',\n')
  query_crashes_per_hour <- paste('  SAFE_DIVIDE(', names(probes.crashes), ', USAGE_HOURS)', ' AS ', names(probes.crashes), '_PER_HOUR', sep='', collapse=',\n')
  additional_filters <- dplyr::case_when(
    !is.null(os) ~ paste("AND normalized_os = '", os,"'", sep='') ,
    TRUE ~ '')
  return(glue(crashes_query_base.,
              tbl = tbl,
              query_crashes = query_crashes,
              query_crashes_probes = paste('  ', names(probes.crashes), collapse=',\n'),
              query_crashes_per_hour = query_crashes_per_hour,
              min_build_id = min_build_id,
              additional_filters = additional_filters
  ))
}

build_scalar_query <- function(probes.scalar.sum, probes.scalar.max, probes.hist.max, slug, tbl, min_build_id, min_build_date, 
                               os=NULL, scalar_query_base. = scalar_query_base){
  query_scalar_sum <- dplyr::case_when(
    !is.null(probes.scalar.sum) ~ paste(paste('  ', 'SUM(COALESCE(', unlist(probes.scalar.sum), ', 0)) AS ', names(probes.scalar.sum), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  query_scalar_max<- dplyr::case_when(
    !is.null(probes.scalar.max) ~ paste(paste('  ', 'MAX(', unlist(probes.scalar.max), ') AS ', names(probes.scalar.max), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  
  query_hist_max <- dplyr::case_when(
    !is.null(probes.hist.max) ~ paste('  ', 
                                      'MAX(COALESCE(`moz-fx-data-shared-prod.udf.histogram_max_key_with_nonzero_value`(', unlist(probes.hist.max), '), 0)) AS ', 
                                      names(probes.hist.max), sep = '', collapse = ',\n'),
    TRUE ~ ''
  )
  
  query_scalar_sum_2 <- dplyr::case_when(
    !is.null(probes.scalar.sum) ~ paste(paste('  ', 'SUM(COALESCE(', names(probes.scalar.sum), ', 0)) AS ', names(probes.scalar.sum), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  query_scalar_max_2 <- dplyr::case_when(
    !is.null(probes.scalar.sum) ~ paste(paste('  ', 'MAX(', names(probes.scalar.max), ') AS ', names(probes.scalar.max), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  
  query_hist_max_2 <- dplyr::case_when(
    !is.null(probes.scalar.sum) ~ paste(paste('  ', 'MAX(', names(probes.hist.max), ') AS ', names(probes.hist.max), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  
  additional_filters <- dplyr::case_when(
    !is.null(os) ~ paste("AND normalized_os = '", os,"'", sep='') ,
    TRUE ~ '')
  return(glue(scalar_query_base, 
              query_scalar_sum = query_scalar_sum,
              query_scalar_max = query_scalar_max,
              query_hist_max = query_hist_max,
              query_scalar_sum_2 = query_scalar_sum_2,
              query_scalar_max_2 = query_scalar_max_2,
              query_hist_max_2 = query_hist_max_2,
              tbl = tbl,
              min_build_id = min_build_id,
              min_build_date = min_build_date,
              additional_filters = additional_filters
  )
  )
}

build_min_build_id_query <- function(tbl, num_build_dates){
  return(
    glue(build_id_query_base, tbl=tbl, num_build_dates = num_build_dates)
  )
}

build_delete_build_records_query <- function(tbl, min_build_id){
  return(glue(delete_build_records_query_base,
              tbl = tbl,
              min_build_id = min_build_id)
  )
}

build_analyzed_probe_query <- function(tbl, probe, os=NULL){
  additional_filters <- dplyr::case_when(
    !is.null(os) ~ paste("AND os = '", os,"'", sep='') ,
    TRUE ~ "AND (os = 'All' OR os IS NULL)"
  )
  return(glue(analyzed_probe_query_base,
              tbl=tbl, additional_filters=additional_filters))
}