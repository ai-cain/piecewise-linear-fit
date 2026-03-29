pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    required property var theme
    property string title: "Chart"
    property string subtitle: ""
    property string xLabel: "X"
    property string yLabel: "Y"
    property string emptyText: "No chart data yet"
    property var seriesList: []
    property var referenceLines: []
    property real bandLower: NaN
    property real bandUpper: NaN
    property color bandColor: "#173b72"
    property int chartHeight: 320
    property bool showLegend: true

    readonly property color plotBackgroundColor: "#0d1727"
    readonly property color plotBorderColor: "#2b3b58"
    readonly property color plotGridColor: "#20314c"
    readonly property color plotTextColor: "#98a7c4"
    readonly property color plotMutedColor: "#6f819f"

    radius: 22
    color: theme.panelAlt
    border.width: 1
    border.color: theme.border

    function allPoints() {
        const result = []
        for (let i = 0; i < seriesList.length; ++i) {
            const series = seriesList[i]
            const points = series.points || []
            for (let j = 0; j < points.length; ++j)
                result.push(points[j])
        }
        return result
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Label {
            text: panel.title
            color: theme.textPrimary
            font.pixelSize: 22
            font.bold: true
        }

        Label {
            visible: text.length > 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: theme.textSecondary
            text: panel.subtitle
        }

        Flow {
            visible: panel.showLegend
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: panel.seriesList

                delegate: Row {
                    required property var modelData
                    spacing: 6
                    visible: modelData.showInLegend !== false
                             && modelData.name !== undefined
                             && String(modelData.name).length > 0

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: modelData.color || panel.theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: modelData.name || ""
                        color: panel.theme.textSecondary
                        font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: panel.chartHeight
            radius: 18
            color: panel.plotBackgroundColor
            border.width: 1
            border.color: panel.plotBorderColor

            Canvas {
                id: canvas
                anchors.fill: parent
                anchors.margins: 12
                antialiasing: true
                renderTarget: Canvas.Image

                Component.onCompleted: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    const width = canvas.width
                    const height = canvas.height
                    ctx.clearRect(0, 0, width, height)

                    const left = 64
                    const right = 22
                    const top = 18
                    const bottom = 48
                    const drawWidth = Math.max(1, width - left - right)
                    const drawHeight = Math.max(1, height - top - bottom)

                    ctx.fillStyle = panel.plotBackgroundColor
                    ctx.fillRect(0, 0, width, height)

                    const points = panel.allPoints()
                    if (points.length === 0) {
                        ctx.fillStyle = panel.plotTextColor
                        ctx.font = "16px sans-serif"
                        ctx.textAlign = "center"
                        ctx.textBaseline = "middle"
                        ctx.fillText(panel.emptyText, width / 2, height / 2)
                        return
                    }

                    let minX = Number(points[0].x)
                    let maxX = Number(points[0].x)
                    let minY = Number(points[0].y)
                    let maxY = Number(points[0].y)

                    for (let i = 0; i < points.length; ++i) {
                        const px = Number(points[i].x)
                        const py = Number(points[i].y)
                        minX = Math.min(minX, px)
                        maxX = Math.max(maxX, px)
                        minY = Math.min(minY, py)
                        maxY = Math.max(maxY, py)
                    }

                    for (let i = 0; i < panel.referenceLines.length; ++i) {
                        const refValue = Number(panel.referenceLines[i].value)
                        minY = Math.min(minY, refValue)
                        maxY = Math.max(maxY, refValue)
                    }

                    if (!Number.isNaN(panel.bandLower))
                        minY = Math.min(minY, panel.bandLower)
                    if (!Number.isNaN(panel.bandUpper))
                        maxY = Math.max(maxY, panel.bandUpper)

                    if (Math.abs(maxX - minX) < 1e-9)
                        maxX = minX + 1
                    if (Math.abs(maxY - minY) < 1e-9)
                        maxY = minY + 1

                    const padX = (maxX - minX) * 0.04
                    const padY = (maxY - minY) * 0.08
                    minX -= padX
                    maxX += padX
                    minY -= padY
                    maxY += padY

                    function mapX(value) {
                        return left + ((value - minX) / (maxX - minX)) * drawWidth
                    }

                    function mapY(value) {
                        return top + drawHeight - ((value - minY) / (maxY - minY)) * drawHeight
                    }

                    function drawText(text, x, y, align, color) {
                        ctx.fillStyle = color
                        ctx.textAlign = align
                        ctx.textBaseline = "middle"
                        ctx.fillText(text, x, y)
                    }

                    ctx.strokeStyle = panel.plotGridColor
                    ctx.lineWidth = 1

                    for (let i = 0; i <= 4; ++i) {
                        const gridY = top + (drawHeight / 4) * i
                        ctx.beginPath()
                        ctx.moveTo(left, gridY)
                        ctx.lineTo(width - right, gridY)
                        ctx.stroke()
                    }

                    for (let i = 0; i <= 4; ++i) {
                        const gridX = left + (drawWidth / 4) * i
                        ctx.beginPath()
                        ctx.moveTo(gridX, top)
                        ctx.lineTo(gridX, height - bottom)
                        ctx.stroke()
                    }

                    if (!Number.isNaN(panel.bandLower) && !Number.isNaN(panel.bandUpper)) {
                        const bandTop = mapY(panel.bandUpper)
                        const bandBottom = mapY(panel.bandLower)
                        ctx.fillStyle = panel.bandColor
                        ctx.globalAlpha = 0.16
                        ctx.fillRect(left, bandTop, drawWidth, bandBottom - bandTop)
                        ctx.globalAlpha = 1.0
                    }

                    for (let i = 0; i < panel.referenceLines.length; ++i) {
                        const refLine = panel.referenceLines[i]
                        const refY = mapY(Number(refLine.value))
                        ctx.strokeStyle = refLine.color || panel.plotMutedColor
                        ctx.lineWidth = refLine.width || 1.5
                        ctx.beginPath()
                        ctx.moveTo(left, refY)
                        ctx.lineTo(width - right, refY)
                        ctx.stroke()
                    }

                    ctx.strokeStyle = panel.plotBorderColor
                    ctx.lineWidth = 1.5
                    ctx.strokeRect(left, top, drawWidth, drawHeight)

                    ctx.font = "12px sans-serif"
                    for (let i = 0; i <= 4; ++i) {
                        const tickY = top + (drawHeight / 4) * i
                        const yValue = maxY - ((maxY - minY) / 4) * i
                        drawText(yValue.toFixed(2), left - 8, tickY, "right", panel.plotMutedColor)
                    }

                    for (let i = 0; i <= 4; ++i) {
                        const tickX = left + (drawWidth / 4) * i
                        const xValue = minX + ((maxX - minX) / 4) * i
                        drawText(xValue.toFixed(2), tickX, height - bottom + 18, "center", panel.plotMutedColor)
                    }

                    ctx.font = "13px sans-serif"
                    drawText(panel.xLabel, width - right, height - 12, "right", panel.plotTextColor)
                    drawText(panel.yLabel, left, 8, "left", panel.plotTextColor)

                    for (let i = 0; i < panel.seriesList.length; ++i) {
                        const series = panel.seriesList[i]
                        const seriesPoints = series.points || []
                        const lineEnabled = Boolean(series.line)
                        const markersEnabled = Boolean(series.markers)
                        const markerSize = Number(series.markerSize || 4)
                        const color = series.color || panel.theme.accent

                        if (lineEnabled && seriesPoints.length > 0) {
                            ctx.strokeStyle = color
                            ctx.lineWidth = Number(series.lineWidth || 2)
                            ctx.beginPath()
                            for (let j = 0; j < seriesPoints.length; ++j) {
                                const point = seriesPoints[j]
                                const px = mapX(Number(point.x))
                                const py = mapY(Number(point.y))
                                if (j === 0)
                                    ctx.moveTo(px, py)
                                else
                                    ctx.lineTo(px, py)
                            }
                            ctx.stroke()
                        }

                        if (markersEnabled) {
                            ctx.fillStyle = color
                            ctx.strokeStyle = panel.plotBackgroundColor
                            ctx.lineWidth = 1
                            for (let j = 0; j < seriesPoints.length; ++j) {
                                const point = seriesPoints[j]
                                const px = mapX(Number(point.x))
                                const py = mapY(Number(point.y))
                                ctx.beginPath()
                                ctx.arc(px, py, markerSize, 0, Math.PI * 2)
                                ctx.fill()
                                ctx.stroke()

                                if (point.label !== undefined && String(point.label).length > 0) {
                                    ctx.fillStyle = panel.plotTextColor
                                    ctx.font = "11px sans-serif"
                                    ctx.textAlign = "left"
                                    ctx.textBaseline = "bottom"
                                    ctx.fillText(String(point.label), px + 6, py - 6)
                                    ctx.fillStyle = color
                                }
                            }
                        }
                    }
                }
            }

            Connections {
                target: panel
                function onSeriesListChanged() { canvas.requestPaint() }
                function onReferenceLinesChanged() { canvas.requestPaint() }
                function onBandLowerChanged() { canvas.requestPaint() }
                function onBandUpperChanged() { canvas.requestPaint() }
            }
        }
    }
}
