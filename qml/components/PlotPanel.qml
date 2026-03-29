pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    required property var theme
    required property var controller

    radius: 22
    color: theme.panelAlt
    border.width: 1
    border.color: theme.border

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Label {
            text: "Chart"
            color: theme.textPrimary
            font.pixelSize: 22
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: theme.textSecondary
            text: controller.hasResults
                  ? "Measured points with the computed piecewise line."
                  : "Measured points preview. The fitted segments appear after analysis."
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: theme.field
            border.width: 1
            border.color: theme.fieldBorder

            Canvas {
                id: canvas
                anchors.fill: parent
                anchors.margins: 12
                antialiasing: true

                Connections {
                    target: controller
                    function onPointsChanged() { canvas.requestPaint() }
                    function onResultsChanged() { canvas.requestPaint() }
                }

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    const width = canvas.width
                    const height = canvas.height
                    const left = 56
                    const right = 24
                    const top = 20
                    const bottom = 40
                    const drawWidth = Math.max(1, width - left - right)
                    const drawHeight = Math.max(1, height - top - bottom)

                    ctx.fillStyle = theme.field
                    ctx.fillRect(0, 0, width, height)

                    const points = controller.pointSeries
                    const segments = controller.segmentResults

                    if (points.length === 0) {
                        ctx.fillStyle = theme.textSecondary
                        ctx.font = "16px sans-serif"
                        ctx.textAlign = "center"
                        ctx.fillText("No chart data yet", width / 2, height / 2)
                        return
                    }

                    let minX = points[0].x
                    let maxX = points[0].x
                    let minY = points[0].y
                    let maxY = points[0].y

                    for (let i = 0; i < points.length; ++i) {
                        minX = Math.min(minX, points[i].x)
                        maxX = Math.max(maxX, points[i].x)
                        minY = Math.min(minY, points[i].y)
                        maxY = Math.max(maxY, points[i].y)
                    }

                    for (let i = 0; i < segments.length; ++i) {
                        const y1 = segments[i].slopeValue * segments[i].xStart + segments[i].interceptValue
                        const y2 = segments[i].slopeValue * segments[i].xEnd + segments[i].interceptValue
                        minX = Math.min(minX, segments[i].xStart)
                        maxX = Math.max(maxX, segments[i].xEnd)
                        minY = Math.min(minY, y1, y2)
                        maxY = Math.max(maxY, y1, y2)
                    }

                    if (Math.abs(maxX - minX) < 1e-9)
                        maxX = minX + 1
                    if (Math.abs(maxY - minY) < 1e-9)
                        maxY = minY + 1

                    const padY = (maxY - minY) * 0.08
                    minY -= padY
                    maxY += padY

                    function mapX(value) {
                        return left + ((value - minX) / (maxX - minX)) * drawWidth
                    }

                    function mapY(value) {
                        return top + drawHeight - ((value - minY) / (maxY - minY)) * drawHeight
                    }

                    ctx.strokeStyle = "#20314c"
                    ctx.lineWidth = 1

                    for (let i = 0; i <= 4; ++i) {
                        const y = top + (drawHeight / 4) * i
                        ctx.beginPath()
                        ctx.moveTo(left, y)
                        ctx.lineTo(width - right, y)
                        ctx.stroke()
                    }

                    ctx.strokeStyle = theme.fieldBorder
                    ctx.lineWidth = 1.5
                    ctx.strokeRect(left, top, drawWidth, drawHeight)

                    if (segments.length > 0) {
                        ctx.strokeStyle = theme.accent
                        ctx.lineWidth = 3

                        for (let i = 0; i < segments.length; ++i) {
                            const startX = mapX(segments[i].xStart)
                            const endX = mapX(segments[i].xEnd)
                            const startY = mapY(segments[i].slopeValue * segments[i].xStart + segments[i].interceptValue)
                            const endY = mapY(segments[i].slopeValue * segments[i].xEnd + segments[i].interceptValue)

                            ctx.beginPath()
                            ctx.moveTo(startX, startY)
                            ctx.lineTo(endX, endY)
                            ctx.stroke()
                        }
                    }

                    ctx.fillStyle = theme.info
                    for (let i = 0; i < points.length; ++i) {
                        const px = mapX(points[i].x)
                        const py = mapY(points[i].y)
                        ctx.beginPath()
                        ctx.arc(px, py, 4, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
            }
        }
    }
}
