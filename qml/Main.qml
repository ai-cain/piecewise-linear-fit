import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 1480
    height: 920
    visible: true
    title: "Segmented Linear Fit Studio"
    color: "#0b1220"

    readonly property color bg: "#0b1220"
    readonly property color panel: "#121b2e"
    readonly property color panelAlt: "#0d1728"
    readonly property color panelBorder: "#22304d"
    readonly property color field: "#0f172a"
    readonly property color fieldBorder: "#253352"
    readonly property color textPrimary: "#eef2ff"
    readonly property color textSecondary: "#9aa7c2"
    readonly property color textMuted: "#70809f"
    readonly property color accent: "#f97316"
    readonly property color accentSoft: "#fb923c"
    readonly property color accentStrong: "#ff6b1a"
    readonly property color success: "#22c55e"
    readonly property color error: "#ef4444"
    readonly property color neutral: "#38bdf8"
    readonly property int panelRadius: 24

    function statusColor() {
        if (appController.statusTone === "success")
            return success
        if (appController.statusTone === "error")
            return error
        return neutral
    }

    component AccentButton: Button {
        id: accentButton
        property color fillColor: accent
        property color foregroundColor: "#08111f"

        implicitHeight: 48

        contentItem: Label {
            text: accentButton.text
            color: accentButton.foregroundColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            font.bold: true
        }

        background: Rectangle {
            radius: 14
            color: !accentButton.enabled ? "#314056" : (accentButton.down ? accentStrong : fillColor)
            border.width: 1
            border.color: !accentButton.enabled ? "#445269" : Qt.lighter(accentStrong, 1.08)
        }
    }

    component GhostButton: Button {
        id: ghostButton
        implicitHeight: 46

        contentItem: Label {
            text: ghostButton.text
            color: ghostButton.enabled ? textPrimary : textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            font.bold: true
        }

        background: Rectangle {
            radius: 14
            color: ghostButton.down ? "#13233a" : field
            border.width: 1
            border.color: fieldBorder
        }
    }

    component InfoChip: Rectangle {
        id: chip
        property string label: ""

        radius: 999
        color: "#12243d"
        border.width: 1
        border.color: "#2b456a"
        implicitWidth: chipLabel.implicitWidth + 22
        implicitHeight: 34

        Label {
            id: chipLabel
            anchors.centerIn: parent
            text: chip.label
            color: textPrimary
            font.pixelSize: 13
            font.bold: true
        }
    }

    component StatTile: Rectangle {
        id: statTile
        property string eyebrow: ""
        property string value: ""
        property color glow: accent

        radius: 18
        color: panelAlt
        border.width: 1
        border.color: Qt.tint(glow, "#77444444")
        implicitWidth: 140
        implicitHeight: 86

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 1
            width: parent.width - 2
            height: 4
            radius: 2
            color: glow
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Label {
                text: statTile.eyebrow
                color: textMuted
                font.pixelSize: 11
                font.capitalization: Font.AllUppercase
                font.bold: true
            }

            Label {
                text: statTile.value
                color: textPrimary
                font.pixelSize: 24
                font.family: "Bahnschrift SemiBold"
                font.bold: true
            }
        }
    }

    FileDialog {
        id: csvDialog
        nameFilters: ["CSV (*.csv)", "Text (*.txt)", "All files (*)"]
        onAccepted: appController.loadCsv(selectedFile)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#08111f" }
            GradientStop { position: 1.0; color: "#10203a" }
        }

        Rectangle {
            x: -120
            y: -80
            width: 360
            height: 360
            radius: 180
            color: "#18345c"
            opacity: 0.22
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -90
            anchors.topMargin: 90
            width: 320
            height: 320
            radius: 160
            color: "#3a1f16"
            opacity: 0.23
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 156
                radius: panelRadius
                color: panel
                border.color: panelBorder
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#162742" }
                        GradientStop { position: 0.58; color: "#101b2d" }
                        GradientStop { position: 1.0; color: "#1d1a2d" }
                    }
                    opacity: 0.58
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 18

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Qt 6 + C++ Backend"
                            color: accent
                            font.pixelSize: 12
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 1.2
                        }

                        Label {
                            text: "Segmented Linear Fit Studio"
                            color: textPrimary
                            font.pixelSize: 34
                            font.family: "Bahnschrift SemiBold"
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: textSecondary
                            font.pixelSize: 15
                            text: "Carga un CSV o genera un rango manual, completa los valores Y y convierte una curva cruda en una funcion lineal por tramos lista para revisar o llevar a PLC."
                        }

                        Row {
                            spacing: 10

                            InfoChip { label: "CSV o manual" }
                            InfoChip { label: "Segmentacion en C++" }
                            InfoChip { label: "Salida PLC" }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 360
                        Layout.fillHeight: true
                        radius: 18
                        color: "#0b1322"
                        border.color: "#294163"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Label {
                                text: "Estado"
                                color: textSecondary
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                color: textPrimary
                                text: appController.statusMessage.length > 0 ? appController.statusMessage : "La app esta lista para cargar un archivo o generar puntos."
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 4
                                radius: 2
                                color: "#17263d"

                                Rectangle {
                                    width: parent.width * 0.88
                                    height: parent.height
                                    radius: 2
                                    color: statusColor()
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                StatTile {
                                    Layout.fillWidth: true
                                    eyebrow: "Puntos"
                                    value: String(appController.pointCount)
                                    glow: accent
                                }

                                StatTile {
                                    Layout.fillWidth: true
                                    eyebrow: "Pendientes"
                                    value: String(appController.missingYCount)
                                    glow: neutral
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.fillHeight: true
                    radius: 22
                    color: panel
                    border.color: panelBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        Label {
                            text: "Fuente de datos"
                            color: textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: textSecondary
                            text: "Usa CSV cuando ya tienes puntos medidos. Usa Manual cuando quieres repartir un rango y llenar Y al costado."
                        }

                        TabBar {
                            id: sourceTabs
                            Layout.fillWidth: true
                            spacing: 6
                            background: Rectangle {
                                radius: 14
                                color: field
                                border.width: 1
                                border.color: fieldBorder
                            }

                            TabButton {
                                id: csvTab
                                text: "CSV"
                                contentItem: Label {
                                    text: csvTab.text
                                    color: csvTab.checked ? "#08111f" : textPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.bold: true
                                }
                                background: Rectangle {
                                    radius: 12
                                    color: csvTab.checked ? accent : "transparent"
                                    border.width: 1
                                    border.color: csvTab.checked ? accentStrong : "transparent"
                                }
                            }

                            TabButton {
                                id: manualTab
                                text: "Manual"
                                contentItem: Label {
                                    text: manualTab.text
                                    color: manualTab.checked ? "#08111f" : textPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.bold: true
                                }
                                background: Rectangle {
                                    radius: 12
                                    color: manualTab.checked ? accent : "transparent"
                                    border.width: 1
                                    border.color: manualTab.checked ? accentStrong : "transparent"
                                }
                            }
                        }

                        StackLayout {
                            Layout.fillWidth: true
                            currentIndex: sourceTabs.currentIndex

                            Rectangle {
                                radius: 16
                                color: field
                                border.color: fieldBorder
                                border.width: 1
                                implicitHeight: 150

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Label {
                                        text: "Importar CSV"
                                        color: textPrimary
                                        font.bold: true
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        color: textSecondary
                                        text: "La app toma las dos primeras columnas del archivo como X e Y."
                                    }

                                    AccentButton {
                                        text: "Seleccionar archivo"
                                        Layout.fillWidth: true
                                        onClicked: csvDialog.open()
                                    }
                                }
                            }

                            Rectangle {
                                radius: 16
                                color: field
                                border.color: fieldBorder
                                border.width: 1
                                implicitHeight: 250

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Label {
                                        text: "Generar puntos"
                                        color: textPrimary
                                        font.bold: true
                                    }

                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 2
                                        columnSpacing: 10
                                        rowSpacing: 10

                                        Label { text: "Minimo"; color: textSecondary }
                                        TextField {
                                            id: minField
                                            text: "0"
                                            Layout.fillWidth: true
                                            color: textPrimary
                                            background: Rectangle {
                                                radius: 12
                                                color: "#0c1626"
                                                border.width: 1
                                                border.color: fieldBorder
                                            }
                                        }

                                        Label { text: "Maximo"; color: textSecondary }
                                        TextField {
                                            id: maxField
                                            text: "300"
                                            Layout.fillWidth: true
                                            color: textPrimary
                                            background: Rectangle {
                                                radius: 12
                                                color: "#0c1626"
                                                border.width: 1
                                                border.color: fieldBorder
                                            }
                                        }

                                        Label { text: "Intervalos"; color: textSecondary }
                                        SpinBox {
                                            id: intervalsBox
                                            from: 1
                                            to: 500
                                            value: 6
                                            editable: true
                                            Layout.fillWidth: true

                                            contentItem: TextInput {
                                                text: intervalsBox.textFromValue(intervalsBox.value, intervalsBox.locale)
                                                color: textPrimary
                                                horizontalAlignment: Qt.AlignHCenter
                                                verticalAlignment: Qt.AlignVCenter
                                                font.pixelSize: 14
                                                readOnly: !intervalsBox.editable
                                                validator: intervalsBox.validator
                                                inputMethodHints: Qt.ImhDigitsOnly
                                            }

                                            background: Rectangle {
                                                radius: 12
                                                color: "#0c1626"
                                                border.width: 1
                                                border.color: fieldBorder
                                            }
                                        }
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        color: textSecondary
                                        text: "Ejemplo recomendado: minimo 0, maximo 300, intervalos 6 -> 7 puntos: 0, 50, 100, 150, 200, 250, 300."
                                    }

                                    AccentButton {
                                        text: "Generar puntos"
                                        Layout.fillWidth: true
                                        onClicked: appController.generatePoints(parseFloat(minField.text),
                                                                                parseFloat(maxField.text),
                                                                                intervalsBox.value)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 16
                            color: field
                            border.color: fieldBorder
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                Label {
                                    text: "Acciones"
                                    color: textPrimary
                                    font.bold: true
                                }

                                AccentButton {
                                    text: "Analizar tramos"
                                    Layout.fillWidth: true
                                    enabled: appController.hasPoints
                                    onClicked: appController.runAnalysis()
                                }

                                GhostButton {
                                    text: "Limpiar puntos"
                                    Layout.fillWidth: true
                                    enabled: appController.hasPoints
                                    onClicked: appController.clearPoints()
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 16
                            color: "#0d1830"
                            border.width: 1
                            border.color: "#264367"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8

                                Label {
                                    text: "Flujo recomendado"
                                    color: textPrimary
                                    font.bold: true
                                }

                                Label {
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    color: textSecondary
                                    text: "1. Carga o genera puntos. 2. Completa la columna Y. 3. Ejecuta el analisis. 4. Revisa ecuaciones y el bloque PLC."
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 22
                    color: panel
                    border.color: panelBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        Label {
                            text: "Puntos"
                            color: textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: textSecondary
                            text: appController.hasPoints
                                  ? appController.pointCount + " puntos cargados, " + appController.missingYCount + " valores Y pendientes."
                                  : "Todavia no hay puntos cargados."
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            StatTile {
                                Layout.fillWidth: true
                                eyebrow: "Total"
                                value: String(appController.pointCount)
                                glow: accent
                            }

                            StatTile {
                                Layout.fillWidth: true
                                eyebrow: "Y pendientes"
                                value: String(appController.missingYCount)
                                glow: neutral
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            radius: 12
                            color: field
                            border.color: fieldBorder
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 10

                                Label {
                                    text: "#"
                                    color: textMuted
                                    font.bold: true
                                    Layout.preferredWidth: 44
                                }

                                Label {
                                    text: "X"
                                    color: textSecondary
                                    font.bold: true
                                    Layout.preferredWidth: 180
                                }

                                Label {
                                    text: "Y"
                                    color: textSecondary
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 16
                            color: field
                            border.color: fieldBorder
                            border.width: 1

                            ListView {
                                id: pointsView
                                anchors.fill: parent
                                anchors.margins: 10
                                clip: true
                                spacing: 8
                                model: appController.pointModel
                                ScrollBar.vertical: ScrollBar { }

                                delegate: Rectangle {
                                    required property int index
                                    required property string displayX
                                    required property string displayY
                                    required property bool validY

                                    width: pointsView.width
                                    height: 52
                                    radius: 12
                                    color: index % 2 === 0 ? "#0d1628" : "#111b30"
                                    border.color: validY ? "#24324e" : accentSoft
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        Rectangle {
                                            Layout.preferredWidth: 44
                                            Layout.fillHeight: true
                                            radius: 10
                                            color: "#13253f"

                                            Label {
                                                anchors.centerIn: parent
                                                text: String(index + 1)
                                                color: textPrimary
                                                font.bold: true
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 180
                                            Layout.fillHeight: true
                                            radius: 10
                                            color: "#09111f"
                                            border.color: "#24324e"
                                            border.width: 1

                                            Label {
                                                anchors.centerIn: parent
                                                text: displayX
                                                color: textPrimary
                                            }
                                        }

                                        TextField {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: displayY
                                            placeholderText: "Ingresa Y"
                                            color: textPrimary
                                            selectByMouse: true
                                            onEditingFinished: appController.updatePointY(index, text)

                                            background: Rectangle {
                                                radius: 10
                                                color: "#0b1323"
                                                border.color: validY ? "#24324e" : accentSoft
                                                border.width: 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 390
                    Layout.fillHeight: true
                    radius: 22
                    color: panel
                    border.color: panelBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        Label {
                            text: "Resultados"
                            color: textPrimary
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: textSecondary
                            text: appController.hasResults
                                  ? appController.summaryText
                                  : "Aqui veras los tramos encontrados, las ecuaciones y el codigo PLC."
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 16
                            color: field
                            border.color: fieldBorder
                            border.width: 1

                            ListView {
                                id: resultsView
                                anchors.fill: parent
                                anchors.margins: 10
                                clip: true
                                spacing: 8
                                model: appController.segmentResults
                                ScrollBar.vertical: ScrollBar { }

                                delegate: Rectangle {
                                    required property string title
                                    required property string range
                                    required property string equation
                                    required property string rsquared

                                    width: resultsView.width
                                    implicitHeight: infoColumn.implicitHeight + 24
                                    radius: 12
                                    color: "#111b30"
                                    border.color: "#24324e"
                                    border.width: 1

                                    ColumnLayout {
                                        id: infoColumn
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6

                                        Label {
                                            text: title
                                            color: accent
                                            font.bold: true
                                            font.pixelSize: 16
                                        }

                                        Label { text: range; color: textPrimary }
                                        Label {
                                            text: equation
                                            color: textPrimary
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                            font.family: "Consolas"
                                            font.pixelSize: 13
                                        }
                                        Label { text: rsquared; color: textSecondary }
                                    }
                                }
                            }
                        }

                        Label {
                            text: "Codigo PLC"
                            color: textPrimary
                            font.bold: true
                        }

                        TextArea {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 220
                            readOnly: true
                            wrapMode: TextArea.WrapAnywhere
                            text: appController.plcCode
                            color: textPrimary
                            font.family: "Consolas"
                            font.pixelSize: 13
                            selectionColor: accent
                            selectedTextColor: bg

                            background: Rectangle {
                                radius: 16
                                color: field
                                border.color: fieldBorder
                                border.width: 1
                            }
                        }
                    }
                }
            }
        }
    }
}
