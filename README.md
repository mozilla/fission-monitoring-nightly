# fission_monitoring_nightly

Code-base to generate monitoring dashboard for ongoing [Fission Nightly "experiment"](https://experimenter.services.mozilla.com/experiments/fission-nightly/). 

Currently, the `analysis.Rmd` reads data in from the initial ETL (< add link >), analyzes the probes relevant to the experiment, then generates a 2nd ETL `moz-fx-data-shared-prod.analysis.fission_monitoring_dashboard_v1`.
