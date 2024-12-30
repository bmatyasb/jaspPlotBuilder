# This module is for the JASP software. A tidyplot based, customizable plot creator.
# Mátyás Bukva, bukvamatyas@gmail.com

tidyPlots <- function(jaspResults, dataset, options) {
  # library(grid)
  # library(ggplot2)
  # library(jaspGraphs)

  # 1. Read dataset if needed -------------------------------------------
  if (is.null(dataset)) {
    dataset <- readDataSetToEnd(
      columns = c(
        options$variableXPlotBuilder,
        options$variableYPlotBuilder,
        options$variableColorPlotBuilder,
        options$idVariablePlotBuilder
      )
    )
  }

  # 2. If the "tidyPlot" doesn't exist yet in jaspResults, create it ----
  if (is.null(jaspResults[["tidyPlot"]])) {

    # Extract variable names
    xVar       <- options$variableXPlotBuilder
    yVar       <- options$variableYPlotBuilder
    colorVar   <- options$variableColorPlotBuilder
    idVar      <- options$idVariablePlotBuilder
    pointShape <- as.numeric(options$pointShape)

    # The user-specified plot dimensions in PIXELS
    plotWidthPx  <- options[["widthPlotBuilder"]]
    plotHeightPx <- options[["heightPlotBuilder"]]

    # Convert from px -> mm for tidyplot -------------------------------

    plotWidthMm  <- plotWidthPx  * 25.4/96
    plotHeightMm <- plotHeightPx * 25.4/96

    # 3. Build the tidyplot object using mm dimensions -----------------
    tidyplot_args <- list(
      data   = dataset,
      width  = plotWidthMm,   # tidyplot expects mm
      height = plotHeightMm
    )

    # Dynamically set x, y, color if columns exist
    if (!is.null(xVar) && xVar %in% colnames(dataset))
      tidyplot_args$x <- rlang::sym(xVar)
    if (!is.null(yVar) && yVar %in% colnames(dataset))
      tidyplot_args$y <- rlang::sym(yVar)
    if (!is.null(colorVar) && colorVar %in% colnames(dataset))
      tidyplot_args$color <- rlang::sym(colorVar)

    # Override color if "color by X" / "color by Y" is chosen
    if (options$colorByVariableX)
      tidyplot_args$color <- rlang::sym(xVar)
    if (options$colorByVariableY)
      tidyplot_args$color <- rlang::sym(yVar)

    # Generate the tidyplot
    tidyplot_obj <- do.call(tidyplot, tidyplot_args) %>%
      add(geom_rangeframe()) %>%
      add(themeJaspRaw()) %>%
      add(theme(axis.text.x = element_text(angle = 45, hjust = 1)))

    # Add mean bar if needed
    if (options$addMeanBar) {
      tidyplot_obj <- tidyplot_obj %>%
        add_mean_bar()
    }

    # Add jittered data points if enabled
    if (options$addDataPoint) {
      tidyplot_obj <- tidyplot_obj %>%
        add_data_points_jitter(
          size         = options[["pointsizePlotBuilder"]],
          shape        = pointShape,
          jitter_width = options[["jitterwPlotBuilder"]],
          jitter_height= options[["jitterhPlotBuilder"]],
          alpha        = options[["alphaPlotBuilder"]]
        )
    }

    # 4. Create the JASP plot object (the "canvas") ---------------------
    #    using the user’s pixel-based dimensions (+ any font margin).
    jaspPlot <- createJaspPlot(
      title  = "Tidy Plot",
      width  = options[["widthPlotBuilder"]],
      height = options[["heightPlotBuilder"]]
    )



    jaspPlot$plotObject <- tidyplot_obj[[1]]


    # Assign the tidyplot (ggplot) object to the JASP plot
    # jaspPlot$plotObject <- tidyplot_obj


    # 5. Set dependencies - if any of these options change, we re-run ---
    jaspPlot$dependOn(
      c(
        "widthPlotBuilder",
        "heightPlotBuilder",
        "widthCanvasPlotBuilder",
        "heightCanvasPlotBuilder",
        "variableColorPlotBuilder",
        "variableXPlotBuilder",
        "variableYPlotBuilder",
        "pointShapePlotBuilder",
        "pointsizePlotBuilder",
        "idVariablePlotBuilder",
        "colorByVariableX",
        "colorByVariableY",
        "addMeanBar",
        "addDataPoint",
        "jitterwPlotBuilder",
        "jitterhPlotBuilder",
        "alphaPlotBuilder"
      )
    )

    # 6. Attach the plot to jaspResults ---------------------------------
    jaspResults[["tidyPlot"]] <- jaspPlot
  }

  # 7. Return the updated jaspResults ------------------------------------
  return(jaspResults)
}


