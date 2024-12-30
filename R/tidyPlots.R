# This module is for the JASP software. A tidyplot based, customizable plot creator.
# Mátyás Bukva, bukvamatyas@gmail.com

#' jaspPlotBuilder
#'
#' @param jaspResults
#' @param dataset
#' @param options
#'
#' @return
#'
#' @import ggplot2
#' @import tidyplots
#' @import ggrepel
#' @import dplyr
#' @import rlang
#' @import jaspBase
#' @import jaspGraphs
#'
#' @export
#'
#' @examples
  tidyPlots <- function(jaspResults, dataset, options) {
    library(ggplot2)
    library(tidyplots)
    library(ggrepel)
    library(dplyr)
    library(rlang)
    library(jaspBase)
    library(jaspGraphs)

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


      # Színezés logika
      legend_position <- "none"  # Alapértelmezett érték: nincs legend

      if (!is.null(colorVar) && colorVar %in% colnames(dataset)) {
        tidyplot_args$color <- rlang::sym(colorVar)
        legend_position <- options[["legendPosistionPlotBuilder"]] # Ha van színezés, legend jobbra
      }

      if (!is.null(options$colorByVariableX) && options$colorByVariableX) {
        tidyplot_args$color <- rlang::sym(xVar)
        legend_position <- options[["legendPosistionPlotBuilder"]]  # Ha van színezés X alapján
      }

      if (!is.null(options$colorByVariableY) && options$colorByVariableY) {
        tidyplot_args$color <- rlang::sym(yVar)
        legend_position <- options[["legendPosistionPlotBuilder"]]  # Ha van színezés Y alapján
      }

      # Generate the tidyplot
      tidyplot_obj <- do.call(tidyplot, tidyplot_args) %>%
        add(geom_rangeframe()) %>%
        add(themeJaspRaw(legend.position = legend_position)) %>%
        add(theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  plot.margin = margin(10, 10, 10, 10)))

      ## Add data points ####
      if (options$addDataPoint) {
        tidyplot_obj <- tidyplot_obj %>%
          add_data_points_jitter(
            dodge_width  = options[["pointDodgePlotBuilder"]],
            size         = options[["pointsizePlotBuilder"]],
            shape        = pointShape,
            jitter_width = options[["jitterwPlotBuilder"]],
            jitter_height= options[["jitterhPlotBuilder"]],
            alpha        = options[["alphaPlotBuilder"]]
          )
      }

      # For some reason, unlike the other parts, this only worked when I used the
      # !!sym() function instead of the regular sym()
      # if (!is.null(idVar) && idVar %in% colnames(dataset)) {
      #   tidyplot_obj <- tidyplot_obj %>%
      #     add_data_labels_repel(!!rlang::sym(idVar),
      #                           position = position_jitterdodge(
      #                             jitter.width = 0.3,  # Jitter a pontok között
      #                             dodge.width = 0.8   # Dodge a csoportok között
      #                           ))
      # }
      #



      ## Histogram ####
      if (options$addHistogram) {
        tidyplot_obj <- tidyplot_obj %>%
          add_histogram(bins = options[["binsPlotBuilder"]],
                        alpha = options[["alphaHistogramPlotBuilder"]])
      }

      ## Boxplot ####
      if (options$addBoxplot) {
        tidyplot_obj <- tidyplot_obj %>%
          add_boxplot(dodge_width = options[["dodgeBoxplotPlotBuilder"]], #0.3
                      alpha = options[["alphaBoxplotPlotBuilder"]], #0.3
                      box_width = options[["widthBoxplotPlotBuilder"]], #0.6
                      linewidth = options[["widthLineBoxplotPlotBuilder"]], # 0.5
                      whiskers_width = options[["widthWhiskersPlotBuilder"]], #0.8
                      show_outliers = options[["outlierBoxplotPlotBuilder"]], #TRUE
                      outlier.size = options[["outlierSizeBoxplotPlotBuilder"]], #0.5
          )
      }

      ## Violin ####

      if (options$addViolin) {
        draw_quantiles <- tryCatch(
          eval(parse(text = options[["drawQuantilesViolinPlotBuilder"]])),
          error = function(e) {
            warning("Invalid quantiles format. Using default: NULL")
            NULL
          }
        )

        tidyplot_obj <- tidyplot_obj %>%
          add_violin(
            draw_quantiles = draw_quantiles, # Numerikus vektorként kell átadni
            alpha = options[["alphaViolinPlotBuilder"]],
            dodge_width = options[["dodgeViolinPlotBuilder"]],
            linewidth = options[["linewidthViolinPlotBuilder"]],
            trim = options[["trimViolinPlotBuilder"]],
            scale = options[["scaleViolinPlotBuilder"]]
          )
      }

      ## Add Count Bar ####

      if (options$addCountBar) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_bar(
            dodge_width = options[["dodgeCountBar"]],
            saturation = options[["saturationCountBar"]],
            alpha = options[["alphaCountBar"]]
          )
      }

      ## Add Count Dash ####
      if (options$addCountDash) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_dash(
            dodge_width = options[["dodgeCountDash"]],
            linewidth = options[["linewidthCountDash"]],
            alpha = options[["alphaCountDash"]]
          )
      }

      ## Add Count Dot ####
      if (options$addCountDot) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_dot(
            dodge_width = options[["dodgeCountDot"]],
            size = options[["sizeCountDot"]],
            alpha = options[["alphaCountDot"]]
          )
      }

      ## Add Count Line ####
      if (options$addCountLine) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_line(
            dodge_width = options[["dodgeCountLine"]],
            linewidth = options[["linewidthCountLine"]],
            alpha = options[["alphaCountLine"]]
          )
      }

      ## Add Count Area ####
      if (options$addCountArea) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_area(
            dodge_width = options[["dodgeCountArea"]],
            alpha = options[["alphaCountArea"]]
          )
      }

      ## Add Count Value ####
      if (options$addCountValue) {
        tidyplot_obj <- tidyplot_obj %>%
          add_count_value(
            fontsize = options[["fontsizeCountValue"]],
            accuracy = eval(parse(text = options[["accuracyCountValue"]])),
            alpha = options[["alphaCountValue"]]
          )
      }

      # Add mean bar
      if (options$addMeanBar) {
        tidyplot_obj <- tidyplot_obj %>%
          add_mean_bar()
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
          "legendPosistionPlotBuilder",

          "addMeanBar",
          "addDataPoint",
          "jitterwPlotBuilder",
          "jitterhPlotBuilder",
          "alphaPlotBuilder",

          #Histogram
          "addHistogram",
          "binsPlotBuilder",
          "alphaHistogramPlotBuilder",

          #Boxplot
          "addBoxplot",
          "dodgeBoxplotPlotBuilder",
          "alphaBoxplotPlotBuilder",
          "widthBoxplotPlotBuilder",
          "widthLineBoxplotPlotBuilder",
          "widthWhiskersPlotBuilder",
          "outlierBoxplotPlotBuilder",
          "outlierSizeBoxplotPlotBuilder",


          #Violin
          "addViolin",
          "alphaViolinPlotBuilder",
          "dodgeViolinPlotBuilder",
          "linewidthViolinPlotBuilder",
          "linewidthViolinPlotBuilder",
          "trimViolinPlotBuilder",
          "scaleViolinPlotBuilder",


          #Count bar
          "addCountBar",
          "dodgeCountBar",
          "saturationCountBar",
          "alphaCountBar",

          #Count dash
          "addCountDash",
          "dodgeCountDash",
          "linewidthCountDash",
          "alphaCountDash",

          # Count Dot
          "addCountDot",
          "dodgeCountDot",
          "sizeCountDot",
          "alphaCountDot",

          # Count Line
          "addCountLine",
          "dodgeCountLine",
          "linewidthCountLine",
          "alphaCountLine",

          # Count Area
          "addCountArea",
          "dodgeCountArea",
          "alphaCountArea",

          # Count Value
          "addCountValue",
          "fontsizeCountValue",
          "accuracyCountValue",
          "alphaCountValue"
        )
      )

      # 6. Attach the plot to jaspResults ---------------------------------
      jaspResults[["tidyPlot"]] <- jaspPlot
    }

    # 7. Return the updated jaspResults ------------------------------------
    return(jaspResults)
  }

