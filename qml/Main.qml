pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"
import "pages"

ApplicationWindow {
    id: window
    width: 1480
    height: 920
    minimumWidth: 1180
    minimumHeight: 760
    visible: true
    title: "Piecewise Linear Fit Studio"

    property int currentPage: 0
    readonly property var controller: appController

    QtObject {
        id: theme
        readonly property color bg: "#09111e"
        readonly property color panel: "#10192b"
        readonly property color panelAlt: "#0c1524"
        readonly property color border: "#24324b"
        readonly property color field: "#0d1727"
        readonly property color fieldBorder: "#2b3b58"
        readonly property color textPrimary: "#edf3ff"
        readonly property color textSecondary: "#98a7c4"
        readonly property color textMuted: "#6f819f"
        readonly property color accent: "#f97316"
        readonly property color accentStrong: "#ff5f0f"
        readonly property color accentSoft: "#fb923c"
        readonly property color success: "#22c55e"
        readonly property color info: "#38bdf8"
    }

    function openCsvDialog() {
        csvDialog.open()
    }

    function statusColor(tone) {
        if (tone === "success")
            return theme.success
        if (tone === "error")
            return theme.accentSoft
        return theme.info
    }

    function pageTitle(index) {
        switch (index) {
        case 0:
            return "Inicio"
        case 1:
            return "Datos"
        case 2:
            return "Resultados"
        default:
            return "Piecewise Linear Fit Studio"
        }
    }

    function pageDescription(index) {
        switch (index) {
        case 0:
            return "Vista general del flujo, accesos rapidos y estado actual de la app."
        case 1:
            return "Carga CSV o genera un rango manual, completa Y y prepara el analisis."
        case 2:
            return "Revisa los tramos calculados, el resumen y el bloque PLC final."
        default:
            return ""
        }
    }

    FileDialog {
        id: csvDialog
        title: "Selecciona un CSV"
        nameFilters: ["CSV (*.csv)", "Text (*.txt)", "All files (*)"]
        onAccepted: window.controller.loadCsv(selectedFile)
    }

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#08111e" }
            GradientStop { position: 1.0; color: "#0d1a31" }
        }

        Rectangle {
            x: -110
            y: -80
            width: 360
            height: 360
            radius: 180
            color: "#16355f"
            opacity: 0.22
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -80
            anchors.topMargin: 90
            width: 300
            height: 300
            radius: 150
            color: "#3b1f17"
            opacity: 0.22
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            radius: 24
            color: theme.panel
            border.width: 1
            border.color: theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Label {
                        text: "Segmented"
                        color: theme.accent
                        font.pixelSize: 12
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }

                    Label {
                        text: "Linear Fit Studio"
                        color: theme.textPrimary
                        font.pixelSize: 28
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: theme.textSecondary
                        text: "Aplicacion desktop en C++/Qt para convertir puntos crudos en una funcion lineal por tramos."
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 18
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        Label {
                            text: "Navegacion"
                            color: theme.textPrimary
                            font.bold: true
                        }

                        NavButton {
                            Layout.fillWidth: true
                            theme: theme
                            text: "Inicio"
                            subtitle: "Resumen y arranque"
                            selected: window.currentPage === 0
                            onClicked: window.currentPage = 0
                        }

                        NavButton {
                            Layout.fillWidth: true
                            theme: theme
                            text: "Datos"
                            subtitle: "CSV, rango y tabla"
                            selected: window.currentPage === 1
                            onClicked: window.currentPage = 1
                        }

                        NavButton {
                            Layout.fillWidth: true
                            theme: theme
                            text: "Resultados"
                            subtitle: "Tramos y PLC"
                            selected: window.currentPage === 2
                            onClicked: window.currentPage = 2
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 18
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Label {
                            text: "Acciones rapidas"
                            color: theme.textPrimary
                            font.bold: true
                        }

                        AppButton {
                            Layout.fillWidth: true
                            theme: theme
                            text: "Abrir CSV"
                            onClicked: window.openCsvDialog()
                        }

                        AppButton {
                            Layout.fillWidth: true
                            theme: theme
                            primary: false
                            text: "Ir a datos"
                            onClicked: window.currentPage = 1
                        }

                        AppButton {
                            Layout.fillWidth: true
                            theme: theme
                            primary: false
                            text: "Ir a resultados"
                            onClicked: window.currentPage = 2
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MetricTile {
                        Layout.fillWidth: true
                        theme: theme
                        label: "Puntos"
                        value: String(window.controller.pointCount)
                        note: window.controller.hasPoints ? "cargados" : "sin datos"
                        accentColor: theme.accent
                    }

                    MetricTile {
                        Layout.fillWidth: true
                        theme: theme
                        label: "Y faltantes"
                        value: String(window.controller.missingYCount)
                        note: "por completar"
                        accentColor: theme.info
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 18
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 10
                                Layout.preferredHeight: 10
                                radius: 5
                                color: window.statusColor(window.controller.statusTone)
                            }

                            Label {
                                text: "Estado actual"
                                color: theme.textPrimary
                                font.bold: true
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: window.controller.statusMessage.length > 0
                                  ? window.controller.statusMessage
                                  : "La app esta lista para trabajar con CSV o modo manual."
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 26
            color: theme.panel
            border.width: 1
            border.color: theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 106
                    radius: 22
                    color: theme.panelAlt
                    border.width: 1
                    border.color: theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Label {
                                text: window.pageTitle(window.currentPage)
                                color: theme.textPrimary
                                font.pixelSize: 30
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                color: theme.textSecondary
                                text: window.pageDescription(window.currentPage)
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 320
                            Layout.fillHeight: true
                            radius: 18
                            color: theme.field
                            border.width: 1
                            border.color: theme.fieldBorder

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 6

                                Label {
                                    text: "Ruta activa"
                                    color: theme.textMuted
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.capitalization: Font.AllUppercase
                                }

                                Label {
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    color: theme.textPrimary
                                    text: "CMake + C++ + QML con flujo separado en paginas."
                                }
                            }
                        }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: window.currentPage

                    HomePage {
                        theme: theme
                        controller: window.controller
                        navigateToPage: function(index) { window.currentPage = index }
                        openCsvDialog: function() { window.openCsvDialog() }
                    }

                    DataPage {
                        theme: theme
                        controller: window.controller
                        navigateToPage: function(index) { window.currentPage = index }
                        openCsvDialog: function() { window.openCsvDialog() }
                    }

                    ResultsPage {
                        theme: theme
                        controller: window.controller
                        navigateToPage: function(index) { window.currentPage = index }
                    }
                }
            }
        }
    }
}
