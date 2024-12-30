//
// Copyright (C) 2013-2024 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls

Form
{
    columns: 1

    infoBottom:
        "## " + qsTr("References") + "\n" +
        "- Allen, M., Poggiali, D., Whitaker, K., Marshall, T. R., van Langen, J., & Kievit, R. A. (2021). " +
                "Raincloud plots: a multi-platform tool for robust data visualization. [version 2; peer review: 2 approved]. " +
                "Wellcome Open Res 2021, 4:63. https://doi.org/10.12688/wellcomeopenres.15191.2.\n" +
        "- Aphalo, P. (2024). _ggpp: Grammar Extensions to 'ggplot2'_. R package version 0.5.6, <https://CRAN.R-project.org/package=ggpp>.\n" +
        "- JASP Team (2024). For this module especially: Ott, V. L., van den Bergh, D., Boutin, B., Goosen, J., Judd, N., Bartoš, F., & Wagenmakers, E. J.\n" +
        "- Judd, N., van Langen, J., Allen, M., & Kievit, R. A. (2024). _ggrain: A Rainclouds Geom for 'ggplot2'_. R package version 0.0.4, https://doi.org/10.32614/CRAN.package.ggrain.\n" +
        "- Wickham, H. (2016). ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York.\n" +
        "- Wickham, H., François, R., Henry, L., Müller, K., & Vaughan, D. (2023). _dplyr: A Grammar of Data Manipulation_. R package version 1.1.4, <https://CRAN.R-project.org/package=dplyr>.\n" +
        "- Wilke C. & Wiernik, B. (2022). _ggtext: Improved Text Rendering Support for 'ggplot2'_. R package version 0.1.2, <https://wilkelab.org/ggtext/>.\n"

    /// Here begins the main plot control
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    VariablesForm
    {
        infoLabel: qsTr("Input")
        AvailableVariablesList { name: "allVariablesListOne" }
        AssignedVariablesList
        {
            name: "variableYPlotBuilder"
            title: qsTr("Y axis")
            allowedColumns: ["scale", "ordinal", "nominal"]
            minNumericLevels: 2
            id: variableYPlotBuilder
            singleVariable: true
            info: qsTr("Select the variable for the Y-axis.")
        }
        AssignedVariablesList
        {
            name: "variableXPlotBuilder"
            title: qsTr("X axis")
            id: variableXPlotBuilder
            allowedColumns: ["scale", "ordinal", "nominal"]
            minLevels: 2
            singleVariable: true
            info: qsTr("Select the variable for the X-axis.")
        }
        AssignedVariablesList
        {
            name: "variableColorPlotBuilder"
            title: qsTr("Group/Color by")
            id: variableColorPlotBuilder
            allowedColumns: ["scale", "ordinal", "nominal"]
            minLevels: 2
            singleVariable: true
            info: qsTr("Select the variable for data grouping, which will also determine the coloring..")
            onCountChanged: {
                if (count > 0) {
                    // Ha a Color változó ki van választva, az X és Y színezést tiltjuk
                    colorByVariableX.checked = false;
                    colorByVariableY.checked = false;
                }
            }
        }
        Group {
            title: qsTr("Or color by")
            columns: 2
            CheckBox
            {
                name: "colorByVariableX"
                label: qsTr("X variable")
                id: colorByVariableX
                // Engedélyezés logika: csak akkor elérhető, ha a Color változó nincs kiválasztva
                enabled: variableXPlotBuilder.count > 0 && variableColorPlotBuilder.count === 0
                onCheckedChanged: {
                    if (checked && variableColorPlotBuilder.count > 0) {
                        checked = false; // Tiltjuk, ha Color ki van választva
                    }
                    if (checked) {
                        colorByVariableY.checked = false; // Az Y színezés automatikusan letiltva, ha az X engedélyezett
                    }
                }
            }
            CheckBox
            {
                name: "colorByVariableY"
                label: qsTr("Y variable")
                id: colorByVariableY
                // Engedélyezés logika: csak akkor elérhető, ha a Color változó nincs kiválasztva
                enabled: variableYPlotBuilder.count > 0 && variableColorPlotBuilder.count === 0
                onCheckedChanged: {
                    if (checked && variableColorPlotBuilder.count > 0) {
                        checked = false; // Tiltjuk, ha Color ki van választva
                    }
                    if (checked) {
                        colorByVariableX.checked = false; // Az X színezés automatikusan letiltva, ha az Y engedélyezett
                    }
                }
            }
        }
        AssignedVariablesList
        {
            name: "variableSplitPlotBuilder"
            title: qsTr("Split by")
            id: variableSplitPlotBuilder
            allowedColumns: ["scale", "ordinal", "nominal"]
            singleVariable: true
            info: qsTr("Points are color coded according to this.")
        }
        CheckBox
        {
            name: "addMeanBar"
            label: qsTr("Show legend")
            id: addMeanBar
            info: qsTr(
                "Shows the legend for the color-coding of the primary factor.<br>" +
                "This option is superseded by a secondary factor; then the legend is always added."
            )
            // A CheckBox csak akkor engedélyezett, ha mind az X, mind az Y változó nem üres
            enabled: variableXPlotBuilder.count > 0 && variableYPlotBuilder.count > 0
        }
    CheckBox
        {
            name: "savePlotBuilder"
            label: qsTr("Save plot")
            id: savePlotBuilder
            info: qsTr(
                "Shows the legend for the color-coding of the primary factor.<br>" +
                "This option is superseded by a secondary factor; then the legend is always added."
            )
            // A CheckBox csak akkor engedélyezett, ha mind az X, mind az Y változó nem üres
            enabled: variableXPlotBuilder.count > 0 && variableYPlotBuilder.count > 0
        }
    }
      // End variables form of the main plot control
Group {
    title: qsTr("Plot size")
    columns: 2

    IntegerField {
        id: plotWidth
        name: "widthPlotBuilder"
        label: qsTr("Width (px)")
        defaultValue: 380
    }

    IntegerField {
        id: plotHeight
        name: "heightPlotBuilder"
        label: qsTr("Height (px)")
        defaultValue: 300
    }
}


    ///////////////////////////////////////////// Data point section ///////////////////////////////////////////////////////

    Section {
        title: qsTr("Add individual data points")
        CheckBox
        {
                name: "addDataPoint"
                label: qsTr("Add individual data points")
                id: addDataPoint
                info: qsTr(
                   "Check this option to show individual data points on the plot."
                )

            columns: 5

            Group{
            DoubleField
            {
                name: "pointsizePlotBuilder"
                id: pointsizePlotBuilder
                label: "Point size"
                value: 1
                min: 0
                max: 10
                info: qsTr(
                   "Set the point size."
                )
            }

            DropDown
            {
                name: "pointShapePlotBuilder"
                label: qsTr("Point shape")
                info: qsTr(
                   "Set the point shape."
                )
                id: pointShapePlotBuilder
                indexDefaultValue: 19
                values:
                [
                    {label: qsTr("Square (0)"), value: "0"},
                    {label: qsTr("Circle (1)"), value: "1"},
                    {label: qsTr("Triangle (2)"), value: "2"},
                    {label: qsTr("Plus (3)"), value: "3"},
                    {label: qsTr("Cross (4)"), value: "4"},
                    {label: qsTr("Diamond (5)"), value: "5"},
                    {label: qsTr("Inverted Triangle (6)"), value: "6"},
                    {label: qsTr("X-Square (7)"), value: "7"},
                    {label: qsTr("Star (8)"), value: "8"},
                    {label: qsTr("Diamond Plus (9)"), value: "9"},
                    {label: qsTr("Circle Filled (10)"), value: "10"},
                    {label: qsTr("Star of David (11)"), value: "11"},
                    {label: qsTr("Square Grid (12)"), value: "12"},
                    {label: qsTr("Circle Cross (13)"), value: "13"},
                    {label: qsTr("Triangle X (14)"), value: "14"},
                    {label: qsTr("Filled Square (15)"), value: "15"},
                    {label: qsTr("Filled Circle (16)"), value: "16"},
                    {label: qsTr("Filled Triangle (17)"), value: "17"},
                    {label: qsTr("Filled Diamond (18)"), value: "18"},
                    {label: qsTr("Bullet Circle (19)"), value: "19"},
                ]
            }}

            Group{
            DoubleField
            {
                name: "jitterhPlotBuilder"
                id: jitterhPlotBuilder
                label: "Jitter height"
                value: 0.3
                min: 0
                max: 10
                info: qsTr(
                   "The 'Add individual data points' option allows you to add individual data points to the plot by applying jitter to them.
                    This means the points are slightly shifted from their original positions to prevent them from overlapping completely, making them more visible. The jitter has two dimensions:
                    height (vertical shift) and width (horizontal shift). Here, you can adjust the height of the jitter."
                )

            }
            DoubleField
            {
                name: "jitterwPlotBuilder"
                id: jitterwPlotBuilder
                label: "Jitter width"
                value: 0.3
                min: 0
                max: 10
                info: qsTr(
                   "See 'Jitter height'. Here, you can adjust the width of the jitter."
                )
            }}


            Group{
            DoubleField
            {
                name: "alphaPlotBuilder"
                id: alphaPlotBuilder
                label: "Transparency"
                value: 1
                min: 0
                max: 1
                info: qsTr(
                   "Set the point transparency"
                )
            }

            DoubleField {
            name: "pointDodgePlotBuilder"
            label: qsTr("Dodge between groups")
            id: pointDodgePlotBuilder
            defaultValue: 0.8
            info: qsTr(
               "If you have a grouping/coloring variable, you can specify the spacing between elements within the same group."
            )
            }}

            // VariablesForm
            // {
            //     preferredHeight: 100 * preferencesModel.uiScale

            //     AvailableVariablesList
            //     {s
            //         name: 				"allVariablesList"
            //         title: 				qsTr("Variables available for labelling")
            //         source: 			[{ name: "allVariablesListOne"}]
            //     }

            //     AssignedVariablesList
            //     {
            //         name: 				"idVariablePlotBuilder"
            //         id: 				idVariablePlotBuilder
            //         singleVariable: 	true
            //         title: 				qsTr("ID variable")
            //     }
            // }
        }
    } // Add individual data points ending


    ////////// DISTRIBUTION //////////


    Section {
        title: qsTr("Represent distribution (histogram, boxplot, violin)")

        Label {
            text: qsTr("Note: For histogram, only Grouping/Color and either X or Y variable can be specified.
X and Y cannot be used simultaneously.")
            wrapMode: Text.Wrap
            color: "red"
        }

        GridLayout {
            columns: 3
            rows: 1

            ///// Histogram /////
            CheckBox {
                name: "addHistogram"
                id: addHistogram
                label: qsTr("Add histogram")
                info: qsTr("Check this option to create histogram for x or y variables.")

                DoubleField {
                    name: "binsPlotBuilder"
                    label: qsTr("Number of bins")
                    id: binsPlotBuilder
                    defaultValue: 30
                }

                DoubleField {
                    name: "alphaHistogramPlotBuilder"
                    label: qsTr("Saturation")
                    id: alphaHistogramPlotBuilder
                    defaultValue: 1
                    min: 0
                    max: 1
                }
            }

            ///// Boxplot /////
            CheckBox {
                name: "addBoxplot"
                id: addBoxplot
                label: qsTr("Add boxplot")
                info: qsTr("Check this option to create boxplot.")

                DoubleField {
                    name: "dodgeBoxplotPlotBuilder"
                    label: qsTr("Dodge between groups")
                    id: dodgeBoxplotPlotBuilder
                    defaultValue: 0.8
                }

                DoubleField {
                    name: "alphaBoxplotPlotBuilder"
                    label: qsTr("Transparency")
                    id: alphaBoxplotPlotBuilder
                    defaultValue: 0.3
                    min: 0
                    max: 1
                }

                DoubleField {
                    name: "widthLineBoxplotPlotBuilder"
                    label: qsTr("Line width")
                    id: widthLineBoxplotPlotBuilder
                    defaultValue: 0.5
                }

                DoubleField {
                    name: "widthBoxplotPlotBuilder"
                    label: qsTr("Boxplot width")
                    id: widthBoxplotPlotBuilder
                    defaultValue: 0.6
                }

                DoubleField {
                    name: "widthWhiskersPlotBuilder"
                    label: qsTr("Whiskers width")
                    id: widthWhiskersPlotBuilder
                    defaultValue: 0.3
                }

                CheckBox {
                    name: "outlierBoxplotPlotBuilder"
                    label: qsTr("Show outliers")
                    id: outlierBoxplotPlotBuilder
                    checked: true
                }

                DoubleField {
                    name: "outlierSizeBoxplotPlotBuilder"
                    label: qsTr("Outlier size")
                    id: outlierSizeBoxplotPlotBuilder
                    defaultValue: 1
                }
            }

            ///// Violin plot /////
            CheckBox {
                name: "addViolin"
                id: addViolin
                label: qsTr("Add violin plot")
                info: qsTr("Check this option to add a violin plot to your visualization.")

                DoubleField {
                    name: "dodgeViolinPlotBuilder"
                    label: qsTr("Dodge between groups")
                    defaultValue: 0.8
                    info: qsTr("Specify quantiles to draw as a vector, e.g., c(0.1, 0.2).")
                }

                DoubleField {
                    name: "alphaViolinPlotBuilder"
                    label: qsTr("Transparency")
                    id: alphaViolinPlotBuilder
                    defaultValue: 0.3
                    min: 0
                    max: 1
                    info: qsTr("Set the transparency level for the violin plot.")
                }

                DoubleField {
                    name: "linewidthViolinPlotBuilder"
                    label: qsTr("Line width")
                    id: linewidthViolinPlotBuilder
                    defaultValue: 0.5
                    info: qsTr("Set the width of the violin plot's outline.")
                }

                FormulaField {
                    name: "drawQuantilesViolinPlotBuilder"
                    label: qsTr("Draw quantiles")
                    defaultValue: "c(0.25, 0.5, 0.75)"
                    info: qsTr("Specify quantiles to draw as a vector, e.g., c(0.1, 0.2).")
                    multiple: true
                }

                CheckBox {
                    name: "trimViolinPlotBuilder"
                    label: qsTr("Trim violins")
                    id: trimViolinPlotBuilder
                    checked: false
                    info: qsTr("Check this option to trim the violin plots.")
                }

                DropDown {
                    name: "scaleViolinPlotBuilder"
                    label: qsTr("Scale method")
                    id: scaleViolinPlotBuilder
                    values: [
                        { label: qsTr("Area"), value: "area" },
                        { label: qsTr("Count"), value: "count" },
                        { label: qsTr("Width"), value: "width" }
                    ]
                    indexDefaultValue: 2
                    info: qsTr("Choose the scaling method for the violin plots.")
                }
            }
        }
    }


    ////////// COUNT and SUM //////////

    Section {
        title: qsTr("Represent amounts (count and sum)")

        Label {
                text: qsTr("Note: Only Grouping/Color and either X or Y variable can be specified. X and Y cannot be used simultaneously.")
                wrapMode: Text.Wrap
                color: "red"
            }

            GridLayout {
                columns: 3
                rows: 2

                CheckBox {
                    name: "addCountBar"
                    label: qsTr("Count bar")
                    info: qsTr("Enable to add a count bar to the plot.")

                    DoubleField {
                        name: "dodgeCountBar"
                        label: qsTr("Dodge width")
                        defaultValue: 0.8
                    }
                    DoubleField {
                        name: "alphaCountBar"
                        label: qsTr("Transparency")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }
                    DoubleField {
                        name: "saturationCountBar"
                        label: qsTr("Saturation")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }
                }

                CheckBox {
                    name: "addCountDash"
                    label: qsTr("Count dash")
                    info: qsTr("Enable to add dashed lines to the plot.")

                    DoubleField {
                        name: "dodgeCountDash"
                        label: qsTr("Dodge width")
                        defaultValue: 0.8
                    }

                    DoubleField {
                        name: "linewidthCountDash"
                        label: qsTr("Line width")
                        defaultValue: 0.5
                    }

                    DoubleField {
                        name: "alphaCountDash"
                        label: qsTr("Transparency")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }

                }

                CheckBox {
                    name: "addCountDot"
                    label: qsTr("Count dot")
                    info: qsTr("Enable to add count dots to the plot.")

                    DoubleField {
                        name: "dodgeCountDot"
                        label: qsTr("Dodge width")
                        defaultValue: 0.8
                    }

                    DoubleField {
                        name: "sizeCountDot"
                        label: qsTr("Dot size")
                        defaultValue: 0.8
                    }

                    DoubleField {
                        name: "alphaCountDot"
                        label: qsTr("Transparency")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }
                }

                CheckBox {
                    name: "addCountLine"
                    label: qsTr("Count line")
                    info: qsTr("Enable to add count lines to the plot.")

                    DoubleField {
                        name: "dodgeCountLine"
                        label: qsTr("Dodge width")
                        defaultValue: 0.8
                    }

                    DoubleField {
                        name: "linewidthCountLine"
                        label: qsTr("Line width")
                        defaultValue: 1
                    }

                    DoubleField {
                        name: "alphaCountLine"
                        label: qsTr("Transparency")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }

                }

                CheckBox {
                    name: "addCountArea"
                    label: qsTr("Count area")
                    info: qsTr("Enable to add a count area to the plot.")

                    DoubleField {
                        name: "dodgeCountArea"
                        label: qsTr("Dodge width")
                        defaultValue: 0.8
                    }
                    DoubleField {
                        name: "alphaCountArea"
                        label: qsTr("Transparency")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }

                }

                CheckBox {
                    name: "addCountValue"
                    label: qsTr("Count value")
                    info: qsTr("Enable to add count values to the plot.")

                    DoubleField {
                        name: "fontsizeCountValue"
                        label: qsTr("Font size")
                        defaultValue: 7
                    }
                    FormulaField {
                        name: "accuracyCountValue"
                        label: qsTr("Accuracy")
                        defaultValue: "0.1"
                        info: qsTr("Specify the desired accuracy as an R expression (e.g., 0.1, 0.01).")
                    }
                    DoubleField {
                        name: "alphaCountValue"
                        label: qsTr("Transparency ")
                        defaultValue: 1
                        min: 0
                        max: 1
                    }
                }
            }


    }

    Section {
        title: qsTr("Represent proportions")
    }
    Section {
        title: qsTr("Add mean geometrics")
    }
    Section {
        title: qsTr("Add median geometrics")
    }
    Section {
        title: qsTr("Add errorbars (SD, SE, CI)")
    }
    Section {
        title: qsTr("Edit style and colors")
        DropDown
        {
            name: "legendPosistionPlotBuilder"
            label: qsTr("Legend position")
            id: legendPosistionPlotBuilder
            indexDefaultValue: 0
            values:
            [
                {label: qsTr("Right"), value: "right"},
                {label: qsTr("Left"), value: "left"},
                {label: qsTr("Bottom"), value: "bottom"},
                {label: qsTr("Top"), value: "top"},
                {label: qsTr("No legend"), value: "none"}

            ]
        }
    }
}// End Form
