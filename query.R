library(glue)

#### Query Strings ####
main_query_base <- "
SELECT 
  client_id,
  DATE(submission_timestamp) AS submission_date,
  `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch AS branch,
  substr(application.build_id,1,8) AS buildid,
{query_hist}
FROM {tbl}
WHERE
  `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch IS NOT NULL
"

hist_query_base.stage_1 <- "
WITH a AS (
  SELECT
    dense_rank() OVER ( ORDER BY client_id) AS c_id,
    substr(application.build_id,1,8) AS buildid,
    `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch AS branch,
    `moz-fx-data-shared-prod`.udf.json_extract_int_map(JSON_EXTRACT({probe_hist}, '$.values')) AS x
  FROM {tbl}
  WHERE `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch IS NOT NULL
  ),
b AS (
  SELECT c_id, buildid,branch,key,coalesce(value,0)  AS value
  FROM a 
  cross join unnest(x)
  ),
c AS ( 
  SELECT c_id, buildid, branch, key, coalesce(sum(value),0) AS value 
  FROM b group by 1,2,3,4) -- STAGE 1

SELECT * 
  FROM c 
ORDER BY buildid, branch,key
"

hist_query_base <- "
WITH a AS (
  SELECT
    dense_rank() OVER ( ORDER BY client_id) AS c_id,
    cast(substr(application.build_id,1,8) as int64) AS build_id,
    `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch AS branch,
    `moz-fx-data-shared-prod`.udf.json_extract_int_map(JSON_EXTRACT({probe_hist}, '$.values')) AS x
  FROM {tbl}
  WHERE `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch IS NOT NULL
  ),
b0 AS (
  SELECT c_id, build_id, branch, key, sum(coalesce(value,0)) AS value
  FROM a 
  CROSS JOIN UNNEST(x)
  WHERE build_id >= {max_build_id}
  GROUP BY 1,2,3,4 
  ),
b1 AS (
  SELECT c_id, build_id, branch, sum(value) AS npings 
  FROM b0 
  GROUP BY 1,2,3),
b  AS (
  SELECT b0.c_id, b0.build_id, b0.branch, key, value/npings AS p 
  FROM b1 JOIN b0 on b0.c_id=b1.c_id and b0.build_id=b1.build_id and b0.branch=b1.branch
),
c1 AS (
  SELECT build_id, branch, count(distinct(c_id)) as nreporting,count(distinct(key)) as K  
  FROM b
  GROUP BY 1,2),
C AS (
  SELECT b.build_id, b.branch, key, max(nreporting) as nreporting, max(K) as K,
        sum(p) as psum
  FROM b JOIN c1 on b.build_id = c1.build_id and b.branch = c1.branch
  GROUP BY 1,2,3)
SELECT build_id, branch,key, nreporting,1/K+psum as psum,K as K, (1/K+psum)/(nreporting+1)  as p
FROM c
"

# Get the total build crashes per client
crashes_query_base <- "
WITH crashes as (
  SELECT 
  client_id,
  cast(substr(build_id,1,8) as int64) AS build_id,
  experiment_branch as branch,
  SUM(usage_hours) as USAGE_HOURS,
{query_crashes}
FROM {tbl}
)

SELECT
  client_id
  build_id
  branch,
  usage_hours,
{query_crashes_probes},
{query_crashes_per_hour}
FROM crashes
WHERE build_id >= {max_build_id}
"

scalar_query_base <- "
WITH daily_agg as (
  SELECT 
    client_id,
    DATE(submission_timestamp) AS submission_date,
    `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch AS branch,
    cast(substr(application.build_id,1,8) as int64) AS buildid,
    {query_scalar_sum}
    {query_scalar_max}
    
  FROM {tbl}
  WHERE
    `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch IS NOT NULL
  GROUP BY 1, 2, 3, 4
)

SELECT 
  client_id as id,
  branch,
  buildid as build_id,
{query_scalar_sum_2}
{query_scalar_max_2}
FROM daily_agg
WHERE buildid >= {max_build_id}
GROUP BY 1, 2, 3
"
  
#### Query Helpers ####
build_main_query <- function(probes.hist, slug, tbl){ ##TODO: Add in scalar probes
  query_hist = dplyr::case_when(
    !is.null(probes.hist) ~ paste('  ', 'JSON_EXTRACT(', unlist(probes.hist), ", '$.values')", ' AS ', names(probes.hist), sep = '', collapse = ',\n'),
    TRUE ~ ''
  )
  main_query = glue(main_query_base,
                    query_hist = query_hist,
                    slug = slug,
                    tbl = tbl
                    )
  return(main_query)
}

build_hist_query <- function(probe.hist, slug, tbl, max_build_id, hist_query_base. = hist_query_base){
  return(glue(hist_query_base., 
              probe_hist = probe.hist,
              tbl = tbl,
              max_build_id = max_build_id
              )
  )
}

build_crash_query <- function(probes.crashes, slug, tbl, max_build_id, crashes_query_base. = crashes_query_base){
  query_crashes <- paste('  ', 'SUM(', unlist(probes.crashes), ') AS ', names(probes.crashes), sep = '', collapse = ',\n') 
  query_crashes_per_hour <- paste('  SAFE_DIVIDE(', names(probes.crashes), ', USAGE_HOURS)', ' AS ', names(probes.crashes), '_PER_HOUR', sep='', collapse=',\n')
  return(glue(crashes_query_base.,
              tbl = tbl,
              query_crashes = query_crashes,
              query_crashes_probes = paste('  ', names(probes.crashes), collapse=',\n'),
              query_crashes_per_hour = query_crashes_per_hour,
              max_build_id = max_build_id
  ))
}

build_scalar_query <- function(probes.scalar.sum, probes.scalar.max, slug, tbl, max_build_id, scalar_query_base. = scalar_query_base){
  query_scalar_sum <- dplyr::case_when(
    !is.null(probes.scalar.sum) ~ paste(paste('  ', 'SUM(COALESCE(', unlist(probes.scalar.sum), ', 0)) AS ', names(probes.scalar.sum), sep = '', collapse = ',\n'), ','),
    TRUE ~ ''
  )
  query_scalar_max<- dplyr::case_when(
    !is.null(probes.scalar.max) ~ paste('  ', 'MAX(', unlist(probes.scalar.max), ') AS ', names(probes.scalar.max), sep = '', collapse = ',\n'),
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
  #query_scalar <- paste('  ', 'AVG(', scalars, ') AS ', scalars, sep = '', collapse = ',\n')
  return(glue(scalar_query_base, 
              query_scalar_sum = query_scalar_sum,
              query_scalar_max = query_scalar_max,
              query_scalar_sum_2 = query_scalar_sum_2,
              query_scalar_max_2 = query_scalar_max_2,
              tbl = tbl,
              max_build_id = max_build_id
  )
  )
}

generate_shell_export_tblname <- function(s) {
  ## `moz-fx-data-shared-prod`.analysis.sguha_ds_283
  ## moz-fx-data-shared-prod:analysis.sguha_ds_283
  y <- gregexpr("^`[a-zA-Z-]+`", s)[[1]]
  if (y > 0) {
    s2 <- attr(y, "match.length")
    u <- substr(s, s2 + 2, nchar(s))
    o <- substr(s, y + 1, s2 - 1)
    return(glue("{o}:{u}"))
  } else {
    stop(glue("Could not find the thing i want in {s}"))
  }
}

