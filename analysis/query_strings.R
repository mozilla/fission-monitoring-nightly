#### Query Strings ####
crash_create_base <- "
WITH crash_ping_data AS (
  SELECT
    submission_timestamp,
    client_id,
    payload.session_id,
    CASE
    WHEN
      SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'enabled'
    WHEN
      NOT SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'disabled'
    END
    AS experiment_branch,
    environment.build.build_id,
    environment.system.os.name AS os_name,
    environment.system.os.version AS os_version,
    IF(payload.process_type = 'main' OR payload.process_type IS NULL, 1, 0) AS main_crash,
    IF(
      REGEXP_CONTAINS(payload.process_type, 'content')
      AND NOT REGEXP_CONTAINS(COALESCE(payload.metadata.ipc_channel_error, ''), 'ShutDownKill'),
      1,
      0
    ) AS content_crash,
    IF(payload.metadata.startup_crash = '1', 1, 0) AS startup_crash,
    IF(
      REGEXP_CONTAINS(payload.process_type, 'content')
      AND REGEXP_CONTAINS(payload.metadata.ipc_channel_error, 'ShutDownKill'),
      1,
      0
    ) AS content_shutdown_crash,
    IF(payload.metadata.oom_allocation_size IS NOT NULL, 1, 0) AS oom_crashes,
    IF(payload.metadata.ipc_channel_error = 'ShutDownKill', 1, 0) AS shutdown_kill_crashes,
    IF(payload.metadata.moz_crash_reason LIKE 'MOZ_CRASH%', 1, 0) AS shutdown_hangs,
    -- 0 for values retrieved from main ping
    0 AS usage_seconds,
    0 AS gpu_crashes,
    0 AS plugin_crashes,
    0 AS gmplugin_crashes
  FROM
    `{tbl.crash.raw}`
  WHERE
    normalized_channel = 'nightly'
    AND cast(substr(environment.build.build_id, 1, 8) as int64) >= {min_build_id}
    AND DATE(submission_timestamp) >= '{min_build_date}'
),
main_ping_data AS (
  SELECT
    submission_timestamp,
    client_id,
    payload.info.session_id,
    CASE
   WHEN
      SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'enabled'
    WHEN
      NOT SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'disabled'
    END
    AS experiment_branch,
    environment.build.build_id,
    environment.system.os.name AS os_name,
    environment.system.os.version AS os_version,
    0 AS main_crash,
    0 AS content_crash,
    0 AS startup_crash,
    0 AS content_shutdown_crash,
    0 AS oom_crashes,
    0 AS shutdown_kill_crashes,
    0 AS shutdown_hangs,
    payload.info.subsession_length AS usage_seconds,
    COALESCE(
      `moz-fx-data-shared-prod`.udf.keyed_histogram_get_sum(
        payload.keyed_histograms.subprocess_crashes_with_dump,
        'gpu'
      ),
      0
    ) AS gpu_crashes,
    COALESCE(
      `moz-fx-data-shared-prod`.udf.keyed_histogram_get_sum(
        payload.keyed_histograms.subprocess_crashes_with_dump,
        'plugin'
      ),
      0
    ) AS plugin_crashes,
    COALESCE(
      `moz-fx-data-shared-prod`.udf.keyed_histogram_get_sum(
        payload.keyed_histograms.subprocess_crashes_with_dump,
        'gmplugin'
      ),
      0
    ) AS gmplugin_crashes
  FROM
    `{tbl.main}`
  WHERE cast(substr(application.build_id, 1, 8) as int64) >= {min_build_id}
  AND DATE(submission_timestamp) >= '{min_build_date}'
),
combined_ping_data AS (
  SELECT
    *
  FROM
    crash_ping_data
  UNION ALL
  SELECT
    *
  FROM
    main_ping_data
)
SELECT
  DATE(submission_timestamp) AS submission_date,
  client_id,
  experiment_branch,
  build_id,
  os_name,
  os_version,
  COUNT(*) AS count,
  SUM(main_crash) AS main_crashes,
  SUM(content_crash) AS content_crashes,
  SUM(startup_crash) AS startup_crashes,
  SUM(content_shutdown_crash) AS content_shutdown_crashes,
  SUM(oom_crashes) AS oom_crashes,
  SUM(shutdown_hangs) AS shutdown_hangs,
  SUM(gpu_crashes) AS gpu_crashes,
  SUM(plugin_crashes) AS plugin_crashes,
  SUM(gmplugin_crashes) AS gmplugin_crashes,
  SUM(
    LEAST(GREATEST(usage_seconds / 3600, 0), 24)
  ) AS usage_hours  -- protect against extreme values
FROM
  combined_ping_data
GROUP BY
  submission_date,
  client_id,
  experiment_branch,
  build_id,
  os_name,
  os_version
"

hist_query_base <- "
WITH a AS (
  SELECT
    dense_rank() OVER ( ORDER BY client_id) AS c_id,
    cast(substr(application.build_id,1,8) as int64) AS build_id,
    CASE
    WHEN
      SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'enabled'
    WHEN
      NOT SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'disabled'
    END
    AS branch,
    mozfun.hist.extract({probe_hist}).values AS x
  FROM {tbl}
  WHERE DATE(submission_timestamp) >= '{min_build_date}'
{additional_filters}
  ),
b0 AS (
  SELECT c_id, build_id, branch, key, sum(coalesce(value,0)) AS value
  FROM a 
  CROSS JOIN UNNEST(x)
  WHERE build_id >= {min_build_id}
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
WHERE experiment_branch is not NULL
{additional_filters}
GROUP BY 1, 2, 3
)
SELECT
  client_id as id,
  build_id,
  branch,
  usage_hours,
{query_crashes_probes},
{query_crashes_per_hour}
FROM crashes
WHERE build_id >= {min_build_id}
"

crashes_ui_query_base <- "
WITH crashes as (
  SELECT 
    client_id,
     CASE
    WHEN
      SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'enabled'
    WHEN
      NOT SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'disabled'
    END
    AS branch,
    cast(substr(application.build_id,1,8) as int64) AS buildid,
    SUM(LEAST(GREATEST(payload.info.subsession_length / 3600, 0), 24))  as USAGE_HOURS,
    {query_crashes}
  FROM {tbl}
  WHERE SUBSTR(application.version, 0, 2) >= '88'
  AND DATE(submission_timestamp) >= '{min_build_date}'
  {additional_filters}
  GROUP BY 1, 2, 3
)
SELECT 
  client_id as id,
  branch,
  buildid as build_id,
{query_crashes_probes},
{query_crashes_per_hour}
FROM crashes
WHERE buildid >= {min_build_id}
"

scalar_query_base <- "
WITH daily_agg as (
  SELECT 
    client_id,
    DATE(submission_timestamp) AS submission_date,
     CASE
    WHEN
      SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'enabled'
    WHEN
      NOT SAFE_CAST(environment.settings.fission_enabled as BOOLEAN)
    THEN
      'disabled'
    END
    AS branch,
    cast(substr(application.build_id,1,8) as int64) AS buildid,
    {query_scalar_sum}
{query_scalar_max}
{query_hist_max}
    
  FROM {tbl}
  WHERE DATE(submission_timestamp) >= '{min_build_date}'
  {additional_filters}
  GROUP BY 1, 2, 3, 4
)
SELECT 
  client_id as id,
  branch,
  buildid as build_id,
{query_scalar_sum_2}
{query_scalar_max_2}
{query_hist_max_2}
FROM daily_agg
WHERE buildid >= {min_build_id}
GROUP BY 1, 2, 3
"

build_id_query_base <- "
SELECT DATE_SUB(MAX(DATE(submission_timestamp)), INTERVAL {num_build_dates} DAY) as max_build_date
FROM {tbl} 
WHERE DATE(SUBMISSION_TIMESTAMP) >= DATE_SUB(CURRENT_DATE(), INTERVAL {num_build_dates} DAY)
"

delete_build_records_query_base <- "
DELETE 
FROM {tbl} 
WHERE build_id >={min_build_id}
"

analyzed_probe_query_base <- "
SELECT * 
FROM {tbl} 
WHERE probe='{probe}'
{additional_filters}
ORDER BY build_id, branch
"
