pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: page
    required property var theme
    required property var controller
    required property var navigateToPage

    function mergeSeries(first, second) {
        const merged = []
        const left = first || []
        const right = second || []

        for (let i = 0; i < left.length; ++i)
            merged.push(left[i])
        for (let i = 0; i < right.length; ++i)
            merged.push(right[i])

        return merged
    }

    ScrollView {
        id: resultsScroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: resultsScroll.availableWidth
            spacing: 18

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Points"
                    value: String(controller.pointCount)
                    note: "current dataset"
                    accentColor: theme.accent
                }

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Segments"
                    value: String(controller.segmentResults.length)
                    note: controller.hasResults ? "computed" : "not available"
                    accentColor: theme.success
                }

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Missing Y"
                    value: String(controller.missingYCount)
                    note: "must be zero to analyze"
                    accentColor: theme.info
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: summaryLayout.implicitHeight + 36
                radius: 22
                color: theme.panelAlt
                border.width: 1
                border.color: theme.border

                ColumnLayout {
                    id: summaryLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Label {
                        text: "Summary"
                        color: theme.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: theme.textSecondary
                        text: controller.hasResults
                              ? controller.summaryText
                              : "Run the analysis from the CSV or Manual page to generate all notebook-style charts."
                    }
                }
            }

            GridLayout {
                id: chartGrid
                Layout.fillWidth: true
                columns: width > 1280 ? 2 : 1
                columnSpacing: 18
                rowSpacing: 18

                PlotPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 430
                    theme: page.theme
                    title: "Measured Data + Piecewise Fit"
                    subtitle: "Original segmented points together with the fitted lines for each segment."
                    xLabel: "Input"
                    yLabel: "Output"
                    showLegend: false
                    seriesList: page.mergeSeries(controller.segmentedPointSeries, controller.fittedLineSeries)
                    emptyText: "Run the analysis to see the combined fit."
                }

                PlotPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 430
                    theme: page.theme
                    title: "Measured Data Only"
                    subtitle: "The same segmented data without the fitted lines."
                    xLabel: "Input"
                    yLabel: "Output"
                    seriesList: controller.segmentedPointSeries
                    emptyText: "Run the analysis to see segmented points."
                }

                PlotPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 430
                    theme: page.theme
                    title: "Piecewise Lines Only"
                    subtitle: "Final equations displayed as individual line segments."
                    xLabel: "Input"
                    yLabel: "Output"
                    seriesList: controller.fittedLineSeries
                    emptyText: "Run the analysis to see the fitted lines."
                }

                PlotPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 430
                    theme: page.theme
                    title: "Residual vs Global Line"
                    subtitle: "Residuals computed against the notebook's single global line reference."
                    xLabel: "Input"
                    yLabel: "Residual"
                    showLegend: false
                    seriesList: controller.globalResidualSeries
                    referenceLines: [{ "value": 0, "color": "#94a3b8", "width": 1.5 }]
                    emptyText: "Run the analysis to inspect the global residuals."
                }

                PlotPanel {
                    Layout.fillWidth: true
                    Layout.columnSpan: chartGrid.columns
                    Layout.preferredHeight: 440
                    theme: page.theme
                    title: "Segment Residual Error"
                    subtitle: "Per-segment residuals with the review tolerance band and out-of-range points highlighted."
                    xLabel: "Input"
                    yLabel: "Residual"
                    chartHeight: 340
                    seriesList: page.mergeSeries(controller.segmentResidualSeries, controller.segmentErrorOutlierSeries)
                    bandLower: -controller.reviewTolerance
                    bandUpper: controller.reviewTolerance
                    bandColor: "#2563eb"
                    referenceLines: [{ "value": 0, "color": "#cbd5e1", "width": 1.5 }]
                    emptyText: "Run the analysis to inspect segment error."
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 460
                spacing: 18

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 22
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: "Segments"
                            color: theme.textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Loader {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            active: true
                            sourceComponent: controller.hasResults ? segmentsComponent : emptyComponent
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 430
                    Layout.fillHeight: true
                    radius: 22
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Label {
                                Layout.fillWidth: true
                                text: "PLC Code"
                                color: theme.textPrimary
                                font.pixelSize: 22
                                font.bold: true
                            }

                            AppButton {
                                Layout.preferredWidth: 132
                                theme: page.theme
                                primary: false
                                text: "Copy PLC"
                                enabled: controller.hasResults
                                onClicked: controller.copyPlcCode()
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: "Generated from the computed piecewise segments."
                        }

                        TextArea {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            readOnly: true
                            wrapMode: TextArea.WrapAnywhere
                            text: controller.plcCode
                            color: theme.textPrimary
                            font.family: "Consolas"
                            font.pixelSize: 13
                            selectionColor: theme.accent
                            selectedTextColor: theme.bg

                            background: Rectangle {
                                radius: 18
                                color: theme.field
                                border.width: 1
                                border.color: theme.fieldBorder
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: emptyComponent

        Rectangle {
            radius: 18
            color: theme.field
            border.width: 1
            border.color: theme.fieldBorder

            Label {
                anchors.centerIn: parent
                text: "No segments yet."
                color: theme.textSecondary
                font.pixelSize: 16
            }
        }
    }

    Component {
        id: segmentsComponent

        Rectangle {
            radius: 18
            color: theme.field
            border.width: 1
            border.color: theme.fieldBorder

            ListView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 8
                model: controller.segmentResults
                ScrollBar.vertical: ScrollBar { }

                delegate: Rectangle {
                    id: segmentCard
                    required property string title
                    required property string range
                    required property string equation
                    required property string rsquared

                    width: ListView.view ? ListView.view.width : 0
                    implicitHeight: infoLayout.implicitHeight + 24
                    radius: 16
                    color: "#111c31"
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        id: infoLayout
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        Label {
                            text: segmentCard.title
                            color: theme.accent
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Label {
                            text: segmentCard.range
                            color: theme.textPrimary
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: segmentCard.equation
                            color: theme.textPrimary
                            font.family: "Consolas"
                            font.pixelSize: 13
                        }

                        Label {
                            text: segmentCard.rsquared
                            color: theme.textSecondary
                        }
                    }
                }
            }
        }
    }
}
