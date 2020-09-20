library(glue)

#### Query Strings ####
main_query_base <- "
SELECT 
  client_id as cid,
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
    substr(application.build_id,1,8) AS build_id,
    `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch AS branch,
    `moz-fx-data-shared-prod`.udf.json_extract_int_map(JSON_EXTRACT({probe_hist}, '$.values')) AS x
  FROM {tbl}
  WHERE `moz-fx-data-shared-prod`.udf.get_key(environment.experiments,'{slug}').branch IS NOT NULL
  ),
b0 AS (
  SELECT c_id, build_id, branch, key, sum(coalesce(value,0)) AS value
  FROM a 
  CROSS JOIN UNNEST(x)
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
 
#### Query Helpers ####
build_main_query <- function(probes.hist, slug, tbl){
  query_hist = paste('  ', 'json_extract(', unlist(probes.hist), ", '$.values')", ' AS ', names(probes.hist), sep = '', collapse = ',\n')
  main_query = glue(main_query_base,
                          query_hist = query_hist,
                          slug = slug,
                          tbl = tbl
                          )
  return(main_query)
}

build_hist_query <- function(probe.hist, slug, tbl, hist_query_base = hist_query_base){
  return(glue(hist_query_base, 
              probe_hist = probe.hist,
              tbl = tbl,
              )
  )
}

