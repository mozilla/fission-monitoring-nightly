#### BigQuery-specific ####
project_id = 'moz-fx-data-bq-data-science'

#### Experiment-specific ####

tbl.main <- '`moz-fx-data-shared-prod`.analysis.fission_monitoring_main_v1'

tbl.crashes <- '`moz-fx-data-shared-prod`.analysis.fission_monitoring_crashes_v1'

tbl.analyzed <- '`moz-fx-data-shared-prod`.analysis.fission_monitoring_crashes_v1'

slug <- 'bug-1622934-pref-webrender-continued-v2-nightly-only-nightly-76-80'

start_date.exp <- as.Date('2020-08-06')

#### Analysis-specific ####
# Breakdown by how probes are analyzed # 
probes.hist <- list(
  "CHECKERBOARDING_SEVERITY" = 'payload.processes.gpu.histograms.checkerboard_severity',
  "CHILD_PROCESS_LAUNCH_MS" = 'payload.histograms.child_process_launch_ms',
  "CONTENT_FRAME_TIME_VSYNC" = 'payload.histograms.content_frame_time_vsync',
  "FX_NEW_WINDOW_MS" = 'payload.histograms.fx_new_window_ms',
  "FX_TAB_SWITCH_COMPOSITE_E10S_MS" = 'payload.histograms.fx_tab_switch_composite_e10s_ms',
  "KEYPRESS_PRESENT_LATENCY_MS" = 'payload.histograms.keypress_present_latency',
  "INPUT_EVENT_RESPONSE_MS" = 'payload.histograms.input_event_response_ms',
  "MEMORY_TOTAL" = 'payload.histograms.memory_total',
  "CYCLE_COLLECTOR_MAX_PAUSE" = 'payload.histograms.cycle_collector_max_pause',
  "GC_MAX_PAUSE_2" = 'payload.histograms.gc_max_pause_ms_2',
  # "GC_MS" = 'payload.histograms.gc_ms', #FIXME: issues regarding import 
  "GC_SLICE_DURING_IDLE" = 'payload.histograms.gc_slice_during_idle',
  "MEMORY_UNIQUE_CONTENT_STARTUP" = 'payload.processes.content.histograms.memory_unique_content_startup',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_1',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_ALL_TABS' = 'payload.histograms.fx_number_of_unique_site_origins_all_tabs',
  'TIME_TO_FIRST_CONTENTFUL_PAINT_MS' = 'payload.histograms.time_to_first_contentful_paint_ms',
  'TIME_TO_FIRST_INTERACTION_MS' = 'payload.histograms.time_to_first_interaction_ms',
  'FX_PAGE_LOAD_MS_2' = 'payload.histograms.fx_page_load_ms_2',
  "LOADED_TAB_COUNT" = 'payload.histograms.loaded_tab_count'
)

probes.scalar <- list(
  "GFX_OMTP_PAINT_WAIT_TIME_RATIO" = 'payload.processes.content.scalars.gfx_omtp_paint_wait_ratio',
  'URI_COUNT' = 'payload.processes.parent.scalars.browser_engagement_total_uri_count',
  'TAB_OPEN_EVENT_COUNT' = 'payload.processes.parent.scalars.browser_engagement_tab_open_event_count',
  'MAX_TAB_COUNT' = 'payload.processes.parent.scalars.browser_engagement_max_concurrent_tab_count',
  ''
)

bs_replicates <- 500

bs_replicates.2 <- 1000


