library(vegawidget)

plotFigure <- function(f, title, width = NULL, height = NULL, pointSize = 10, ydomains, yaxislab = "Estimate", LA = 0) {
  ## Need error bars
  ## Jitter the points to not overlap(use dtatetime and plot the x axis as Date, make Label also date)
  ## For enabled, hoverover, keep Rel. Diff wrt Disabled - for Disabled
  u3 <- list(
    `$schema` = vega_schema(),
    data = list(values = f),
    config = list(legend = list(direction = "horizontal", orient = "top", title = NULL)),
    title = list(text = glue(title), anchor = "start", fontWeight = "normal"),
    width = if (is.null(width)) 1200 else width,
    height = if (is.null(height)) 300 else height,
    autosize = list(type = "fit", contains = "content"),
    layer = list(
      list(
        selection = list(grid = list(type = "interval", bind = "scales")),
        transform = list(list(calculate = "format(datum.est,'.2f')+' ('+format(datum.low,'.2f')+','+format(datum.high,'.2f')+')'", as = "Estimate")),
        mark = list(type = "line", point = "true"), #' transparent'),
        encoding = list(
          x = list(
            field = "build_id2", type = "temporal", timeUnit = "yearmonthdatehoursminutes",
            axis = list(
              title = "BuildIDs on this Date",
              titleFontWeight = "light",
              tickExtra = FALSE
              #                                     , tickCount=length(unique(xx$build_id))
              , grid = FALSE,
              labelOverlap = "parity",
              format = "%Y%m%d",
              labelAngle = LA
            ),
            scale = list(type = "utc")
          ),
          y = list(
            field = "est",
            scale = list(zero = FALSE) # domain=ydomains)
            , type = "quantitative",
            axis = list(
              title = yaxislab,
              titleFontSize = 11
            )
          ),
          color = list(field = "Branch", type = "nominal", scale = list(scheme = "set1")),
          tooltip = list(
            list(field = "build_id", type = "nominal"),
            list(field = 'num_clients', type='nominal'),
            list(field = "Branch", type = "ordinal"),
            list(field = "Estimate", type = "ordinal"),
            list(field = "UsingDataTill", type = "temporal"),
            list(field = "RelativeDiff", type = "nominal")
          )
        )
    ),
    list(
      mark = list(type = "errorband"), # ,"strokeDash"=list(4, 2)),
      encoding = list(
        x = list(
          field = "build_id2", type = "temporal", timeUnit = "yearmonthdatehoursminutes",
          axis = list(title = "BuildIDs on this Date", grid = FALSE, labelOverlap = "parity", format = "%Y%m%d", labelAngle = 360),
          scale = list(type = "utc")
        ),
        y = list(field = "low", type = "quantitative", axis = list(title = ""), grid = FALSE, scale = list(zero = FALSE)),
        y2 = list(field = "high", type = "quantitative", axis = list(title = ""), grid = FALSE),
        color = list(field = "Branch", type = "nominal"),
        opacity = list(value = 0.15),
        tooltip = NULL
      )
    )
  )
  )
  u3
}

create.figure <- function(df, title, width = NULL, height = NULL, yaxislab = "Estimate", 
                          pointSize = 65, expandFrac = 0.05, LA = 0,
                          buildLimit = NULL) {
  w <- df
  if (!is.null(buildLimit)) {
    w <- w[build_id >= strftime((as.Date(buildLimit, "%Y%m%d") - as.difftime(6, "months")), "%Y%m%d")]
  }
  w <- w[,
         {
           reld <- .SD[branch == "reldiff(TvsC) %", ]
           X <- .SD[branch != "reldiff(TvsC) %", ]
           if (sign(reld$low) == sign(reld$high)) {
             ch <- "✅"
           } else {
             ch <- "⁓"
           }
           X <- X[order(branch), ][, RelativeDiff := c("not applicable", glue("{e}% ({l},{h}) {ch}", e = round(reld$est, 1), l = round(reld$low, 1), h = round(reld$high, 1)))]
           X
         },
         by = list(date_computed, build_id)
  ]
  xx <- w[, list(
    UsingDataTill = date_computed, build_id = parse_date(build_id),
    num_clients = nreporting,
    Branch = branch,
    est, low, high, RelativeDiff
  )]
  xx <- xx[Branch == "enabled", build_id2 := format_iso_8601(build_id - as.difftime(0, units = "mins"))]
  xx <- xx[Branch == "disabled", build_id2 := format_iso_8601(build_id + as.difftime(0, units = "mins"))]
  MYDM <- expandlims(xx[, c(est, low, high)], expandFrac)
  xy <- plotFigure(xx, title = title, width = width, height = height, yaxislab = yaxislab, pointSize = pointSize, LA = LA, ydomains = MYDM)
}


vw <- function(xy, actions = TRUE) {
  vegawidget(as_vegaspec(xy), embed = vega_embed(actions = actions, renderer = "canvas"))
}

expandlims <- function(s, p = 0.05) {
  r <- range(s)
  r + c(-1, 1) * diff(r) * p / 2
}

remove_na <- function(df){
  if (nrow(df) > 0) {
    df_clean <- df %>% 
      filter(!build_id %in% (df[rowSums(is.na(df)) > 0,] %>% pull(build_id))) 
  } else{
    df_clean <- df
  }
  return(df_clean)
}
