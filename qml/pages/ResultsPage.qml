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

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MetricTile {
                Layout.fillWidth: true
                theme: page.theme
                label: "Puntos"
                value: String(controller.pointCount)
                note: "procesados"
                accentColor: theme.accent
            }

            MetricTile {
                Layout.fillWidth: true
                theme: page.theme
                label: "Segmentos"
                value: String(controller.segmentResults.length)
                note: controller.hasResults ? "en la solucion" : "sin calcular"
                accentColor: theme.success
            }

            MetricTile {
                Layout.fillWidth: true
                theme: page.theme
                label: "Pendientes"
                value: String(controller.missingYCount)
                note: "valores Y faltantes"
                accentColor: theme.info
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 22
            color: theme.panelAlt
            border.width: 1
            border.color: theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                Label {
                    text: "Resumen"
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
                          : "Aun no hay resultados. Ve a Datos, completa la tabla y ejecuta el analisis."
                }

                AppButton {
                    theme: page.theme
                    primary: false
                    text: "Volver a datos"
                    onClicked: page.navigateToPage(1)
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: true
            sourceComponent: controller.hasResults ? resultsComponent : emptyComponent
        }
    }

    Component {
        id: emptyComponent

        Rectangle {
            radius: 24
            color: theme.panelAlt
            border.width: 1
            border.color: theme.border

            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 560)
                spacing: 12

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Todavia no existe un analisis para mostrar."
                    color: theme.textPrimary
                    font.pixelSize: 28
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Cuando termines de cargar o escribir los puntos, corre el analisis desde la pagina Datos."
                    color: theme.textSecondary
                }

                AppButton {
                    Layout.alignment: Qt.AlignHCenter
                    theme: page.theme
                    text: "Ir a datos"
                    onClicked: page.navigateToPage(1)
                }
            }
        }
    }

    Component {
        id: resultsComponent

        RowLayout {
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
                        text: "Tramos encontrados"
                        color: theme.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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

            Rectangle {
                Layout.preferredWidth: 420
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
                        text: "Codigo PLC"
                        color: theme.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: theme.textSecondary
                        text: "Bloque generado automaticamente a partir de los segmentos encontrados."
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
