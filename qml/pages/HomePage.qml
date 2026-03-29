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
    required property var openCsvDialog

    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: homeScroll.availableWidth
            spacing: 18

            Rectangle {
                id: heroCard
                Layout.fillWidth: true
                implicitHeight: heroContent.implicitHeight + 40
                radius: 24
                color: theme.panelAlt
                border.width: 1
                border.color: theme.border

                ColumnLayout {
                    id: heroContent
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Label {
                        text: "De notebook crudo a app desktop"
                        color: theme.accent
                        font.pixelSize: 12
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }

                    Label {
                        text: "Ahora el flujo esta dividido por paginas para que se sienta mas como herramienta de escritorio."
                        color: theme.textPrimary
                        font.pixelSize: 30
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: theme.textSecondary
                        text: "Usa Inicio para orientarte, Datos para cargar o generar puntos, y Resultados para revisar la aproximacion final por tramos y el codigo PLC."
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        AppButton {
                            theme: page.theme
                            text: "Ir a datos"
                            onClicked: page.navigateToPage(1)
                        }

                        AppButton {
                            theme: page.theme
                            primary: false
                            text: "Abrir CSV"
                            onClicked: page.openCsvDialog()
                        }

                        AppButton {
                            theme: page.theme
                            primary: false
                            text: "Ver resultados"
                            onClicked: page.navigateToPage(2)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Puntos"
                    value: String(controller.pointCount)
                    note: controller.hasPoints ? "listos para editar" : "sin cargar todavia"
                    accentColor: theme.accent
                }

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Pendientes"
                    value: String(controller.missingYCount)
                    note: "valores Y por completar"
                    accentColor: theme.info
                }

                MetricTile {
                    Layout.fillWidth: true
                    theme: page.theme
                    label: "Segmentos"
                    value: String(controller.segmentResults.length)
                    note: controller.hasResults ? "calculados" : "sin analisis"
                    accentColor: theme.success
                }
            }

            RowLayout {
                id: infoRow
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(inputsCard.implicitHeight, segmentsCard.implicitHeight)
                spacing: 18

                Rectangle {
                    id: inputsCard
                    Layout.fillWidth: true
                    implicitHeight: inputsContent.implicitHeight + 36
                    radius: 22
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        id: inputsContent
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "Entradas soportadas"
                            color: theme.textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: "1. CSV con dos columnas numericas. 2. Rango manual usando minimo, maximo e intervalos para repartir puntos y luego llenar Y."
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: "El notebook original se mantiene como referencia en files/segmented_linear_fit.ipynb."
                        }
                    }
                }

                Rectangle {
                    id: segmentsCard
                    Layout.fillWidth: true
                    implicitHeight: segmentsContent.implicitHeight + 36
                    radius: 22
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        id: segmentsContent
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "Por que por tramos"
                            color: theme.textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: "Cuando una sola recta no representa bien la curva, el analisis parte la relacion en segmentos consecutivos y calcula una recta distinta para cada rango."
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: "Eso deja una salida mucho mas util para PLC o logica embebida: IF / ELSIF por rangos con ecuaciones simples."
                        }
                    }
                }
            }

            Rectangle {
                id: flowCard
                Layout.fillWidth: true
                implicitHeight: flowContent.implicitHeight + 36
                radius: 22
                color: theme.panelAlt
                border.width: 1
                border.color: theme.border

                ColumnLayout {
                    id: flowContent
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Label {
                        text: "Flujo recomendado"
                        color: theme.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Repeater {
                        model: [
                            "1. Ve a Datos y carga un CSV o genera el rango manual.",
                            "2. Completa los valores Y faltantes en la tabla editable.",
                            "3. Ejecuta el analisis y revisa el resumen de segmentos.",
                            "4. Abre Resultados y copia o adapta el bloque PLC."
                        ]

                        delegate: Rectangle {
                            required property string modelData
                            Layout.fillWidth: true
                            radius: 16
                            color: theme.field
                            border.width: 1
                            border.color: theme.fieldBorder
                            implicitHeight: stepLabel.implicitHeight + 24

                            Label {
                                id: stepLabel
                                anchors.fill: parent
                                anchors.margins: 12
                                wrapMode: Text.WordWrap
                                text: modelData
                                color: theme.textPrimary
                            }
                        }
                    }
                }
            }
        }
    }
}
