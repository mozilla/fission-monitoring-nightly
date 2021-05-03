#### Experiment-specific ####

slug <- 'bug-1660366-pref-ongoing-fission-nightly-experiment-nightly-83-100'
exp_min_build_id <- 20201012

#### Analysis-specific ####
# Breakdown by how probes are analyzed # 
probes.hist <- list(
  'CONTENT_PROCESS_COUNT' = 'payload.histograms.content_process_count',
  # 'CONTENT_PROCESS_MAX' =  'payload.histograms.content_process_max',
  "CHECKERBOARDING_SEVERITY" = 'payload.processes.gpu.histograms.checkerboard_severity',
  "CHILD_PROCESS_LAUNCH_MS" = 'payload.histograms.child_process_launch_ms',
  "CONTENT_FRAME_TIME_VSYNC" = 'payload.histograms.content_frame_time_vsync',
  "FX_NEW_WINDOW_MS" = 'payload.histograms.fx_new_window_ms',
  "FX_TAB_SWITCH_COMPOSITE_E10S_MS" = 'payload.histograms.fx_tab_switch_composite_e10s_ms',
  # "KEYPRESS_PRESENT_LATENCY_MS" = 'payload.histograms.keypress_present_latency',
  "KEYPRESS_PRESENT_LATENCY_MS" = 'payload.processes.gpu.histograms.keypress_present_latency',
  # "INPUT_EVENT_RESPONSE_MS" = 'payload.histograms.input_event_response_ms',
  "INPUT_EVENT_RESPONSE_MS" = 'payload.processes.content.histograms.input_event_response_startup_ms',
  "MEMORY_TOTAL" = 'payload.histograms.memory_total',
  "CYCLE_COLLECTOR_MAX_PAUSE" = 'payload.histograms.cycle_collector_max_pause',
  "CYCLE_COLLECTOR_MAX_PAUSE_CONTENT" = 'payload.processes.content.histograms.cycle_collector_max_pause',
  "GC_MAX_PAUSE_2" = 'payload.histograms.gc_max_pause_ms_2',
  "GC_MAX_PAUSE_2_CONTENT" = 'payload.processes.content.histograms.gc_max_pause_ms_2',
  "GC_MS" = 'payload.histograms.gc_ms', 
  "GC_MS_CONTENT" = 'payload.processes.content.histograms.gc_ms', 
  "GC_SLICE_DURING_IDLE" = 'payload.histograms.gc_slice_during_idle',
  "GC_SLICE_DURING_IDLE_CONTENT" = 'payload.processes.content.histograms.gc_slice_during_idle',
  "MEMORY_UNIQUE_CONTENT_STARTUP" = 'payload.processes.content.histograms.memory_unique_content_startup',
  # 'TIME_TO_FIRST_CONTENTFUL_PAINT_MS' = 'payload.histograms.time_to_first_contentful_paint_ms',
  # 'TIME_TO_FIRST_CONTENTFUL_PAINT_MS' = 'payload.processes.content.histograms.time_to_first_contentful_paint_ms',
  'PERF_FIRST_CONTENTFUL_PAINT_MS' = 'payload.processes.content.histograms.perf_first_contentful_paint_ms',
  # 'TIME_TO_FIRST_INTERACTION_MS' = 'payload.histograms.time_to_first_interaction_ms',
  'TIME_TO_FIRST_INTERACTION_MS' = 'payload.processes.content.histograms.time_to_first_interaction_ms',
  # 'FX_PAGE_LOAD_MS_2' = 'payload.histograms.fx_page_load_ms_2',
  'PERF_PAGE_LOAD_TIME_MS' = 'payload.processes.content.histograms.perf_page_load_time_ms',
  "LOADED_TAB_COUNT" = 'payload.histograms.loaded_tab_count',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_1' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_1',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_2_4' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_2_4',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_5_9' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_5_9',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_10_14' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_10_14',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_15_19' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_15_19',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_20_24' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_20_24',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_25_29' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_25_29',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_30_34' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_30_34',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_35_39' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_35_39',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_40_44' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_40_44',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_45_49' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_45_49',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_PER_LOADED_TABS_50_PLUS' = 'payload.histograms.fx_number_of_unique_site_origins_per_loaded_tabs_50_plus',
  'FX_NUMBER_OF_UNIQUE_SITE_ORIGINS_ALL_TABS' = 'payload.histograms.fx_number_of_unique_site_origins_all_tabs'
)

probes.hist.perc.95 <- list(
  'CONTENT_PROCESS_COUNT_95TH' = 'payload.histograms.content_process_count',
  "CHECKERBOARDING_SEVERITY_95TH" ='payload.processes.gpu.histograms.checkerboard_severity',
  "CHILD_PROCESS_LAUNCH_MS_95TH" ='payload.histograms.child_process_launch_ms',
  "CONTENT_FRAME_TIME_VSYNC_95TH" ='payload.histograms.content_frame_time_vsync',
  "FX_NEW_WINDOW_MS_95TH" ='payload.histograms.fx_new_window_ms',
  "FX_TAB_SWITCH_COMPOSITE_E10S_MS_95TH" ='payload.histograms.fx_tab_switch_composite_e10s_ms',
  # "KEYPRESS_PRESENT_LATENCY_MS_95TH" ='payload.histograms.keypress_present_latency',
  "KEYPRESS_PRESENT_LATENCY_MS_95TH" ='payload.processes.gpu.histograms.keypress_present_latency',
  # "INPUT_EVENT_RESPONSE_MS_95TH" ='payload.histograms.input_event_response_ms',
  "INPUT_EVENT_RESPONSE_MS_95TH" ='payload.processes.content.histograms.input_event_response_startup_ms',
  "MEMORY_TOTAL_95TH" ='payload.histograms.memory_total',
  "CYCLE_COLLECTOR_MAX_PAUSE_95TH" ='payload.histograms.cycle_collector_max_pause',
  "CYCLE_COLLECTOR_MAX_PAUSE_CONTENT_95TH" ='payload.processes.content.histograms.cycle_collector_max_pause',
  "GC_MAX_PAUSE_2_95TH" ='payload.histograms.gc_max_pause_ms_2',
  "GC_MAX_PAUSE_2_CONTENT_95TH" ='payload.processes.content.histograms.gc_max_pause_ms_2',
  "GC_MS_95TH" ='payload.processes.content.histograms.gc_ms', 
  "GC_SLICE_DURING_IDLE_95TH" ='payload.histograms.gc_slice_during_idle',
  "GC_SLICE_DURING_IDLE_CONTENT_95TH" ='payload.processes.content.histograms.gc_slice_during_idle',
  "MEMORY_UNIQUE_CONTENT_STARTUP_95TH" ='payload.processes.content.histograms.memory_unique_content_startup',
  # 'TIME_TO_FIRST_CONTENTFUL_PAINT_MS' = 'payload.histograms.time_to_first_contentful_paint_ms',
  # 'TIME_TO_FIRST_CONTENTFUL_PAINT_MS_95TH' = 'payload.processes.content.histograms.time_to_first_contentful_paint_ms',
  'PERF_FIRST_CONTENTFUL_PAINT_MS_95TH' = 'payload.processes.content.histograms.perf_first_contentful_paint_ms',
  # 'TIME_TO_FIRST_INTERACTION_MS' = 'payload.histograms.time_to_first_interaction_ms',
  'TIME_TO_FIRST_INTERACTION_MS_95TH' = 'payload.processes.content.histograms.time_to_first_interaction_ms',
  #'FX_PAGE_LOAD_MS_2_95TH' = 'payload.histograms.fx_page_load_ms_2',
  'PERF_PAGE_LOAD_TIME_MS_95TH' = 'payload.processes.content.histograms.perf_page_load_time_ms',
  "LOADED_TAB_COUNT_95TH" ='payload.histograms.loaded_tab_count'
)

probes.hist.max <- list(
  'CONTENT_PROCESS_MAX' = 'payload.histograms.content_process_max'
)

probes.scalar.sum <- list(
  'ACTIVE_TICKS' = 'payload.processes.parent.scalars.browser_engagement_active_ticks',
  'SUBSESSION_LENGTH' = 'payload.info.subsession_length',
  'URI_COUNT' = 'payload.processes.parent.scalars.browser_engagement_total_uri_count'
)

# probes.scalar.mean <- list(
# 
# )

probes.scalar.max <- list(
  "GFX_OMTP_PAINT_WAIT_TIME_RATIO" = 'payload.processes.content.scalars.gfx_omtp_paint_wait_ratio',
  'TAB_OPEN_EVENT_COUNT' = 'payload.processes.parent.scalars.browser_engagement_tab_open_event_count',
  'MAX_TAB_COUNT' = 'payload.processes.parent.scalars.browser_engagement_max_concurrent_tab_count'
)

probes.crashes <- list(
  'MAIN_CRASHES' = 'main_crashes',
  'CONTENT_CRASHES' = 'content_crashes',
  'STARTUP_CRASHES' = 'startup_crashes',
  'CONTENT_SHUTDOWN_CRASHES' = 'content_shutdown_crashes',
  'GPU_CRASHES' = 'gpu_crashes',
  'PLUGIN_CRASHES' = 'plugin_crashes',
  'GMPLUGIN_CRASHES' = 'gmplugin_crashes',
  'OOM_CRASHES' = 'oom_crashes',
  # 'SHUTDOWN_KILL_CRASHES' = 'shutdown_kill_crashes',
  'SHUTDOWN_HANGS' = 'shutdown_hangs'
)

probes.crashes.ui <- list(
  'UNSUBMITTED_UI_PRESENTED' = 'payload.processes.parent.scalars.dom_contentprocess_unsubmitted_ui_presented',
  'CRASH_SUBFRAME_UI_PRESENTED' = 'payload.processes.parent.scalars.dom_contentprocess_crash_subframe_ui_presented',
  'CRASH_TAB_UI_PRESENTED' = 'payload.processes.parent.scalars.dom_contentprocess_crash_tab_ui_presented'
)

# Bootstrapping

bs_replicates <- 500

bs_replicates.2 <- 1000

# Filtering
num_build_dates <- 10
perc.high <- 0.999

