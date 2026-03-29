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
    property int sourceMode: 0

    RowLayout {
        anchors.fill: parent
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            radius: 22
            color: theme.panelAlt
            border.width: 1
            border.color: theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Label {
                    text: "Origen de datos"
                    color: theme.textPrimary
                    font.pixelSize: 22
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: theme.textSecondary
                    text: "Escoge CSV si ya tienes mediciones. Escoge Manual si quieres repartir el rango y escribir Y al costado."
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    AppButton {
                        Layout.fillWidth: true
                        theme: page.theme
                        text: "CSV"
                        primary: page.sourceMode === 0
                        onClicked: page.sourceMode = 0
                    }

                    AppButton {
                        Layout.fillWidth: true
                        theme: page.theme
                        text: "Manual"
                        primary: page.sourceMode === 1
                        onClicked: page.sourceMode = 1
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    currentIndex: page.sourceMode

                    Rectangle {
                        radius: 18
                        color: theme.field
                        border.width: 1
                        border.color: theme.fieldBorder
                        implicitHeight: 190

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Label {
                                text: "Importar CSV"
                                color: theme.textPrimary
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                color: theme.textSecondary
                                text: "La app toma las dos primeras columnas numericas del archivo como X e Y. En files/ tienes CSV de ejemplo."
                            }

                            AppButton {
                                Layout.fillWidth: true
                                theme: page.theme
                                text: "Seleccionar archivo"
                                onClicked: page.openCsvDialog()
                            }
                        }
                    }

                    Rectangle {
                        radius: 18
                        color: theme.field
                        border.width: 1
                        border.color: theme.fieldBorder
                        implicitHeight: 280

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Label {
                                text: "Generar rango"
                                color: theme.textPrimary
                                font.bold: true
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 10

                                Label {
                                    text: "Minimo"
                                    color: theme.textSecondary
                                }

                                TextField {
                                    id: minimumField
                                    Layout.fillWidth: true
                                    text: "0"
                                    color: theme.textPrimary
                                    selectByMouse: true
                                    background: Rectangle {
                                        radius: 12
                                        color: theme.panel
                                        border.width: 1
                                        border.color: theme.fieldBorder
                                    }
                                }

                                Label {
                                    text: "Maximo"
                                    color: theme.textSecondary
                                }

                                TextField {
                                    id: maximumField
                                    Layout.fillWidth: true
                                    text: "300"
                                    color: theme.textPrimary
                                    selectByMouse: true
                                    background: Rectangle {
                                        radius: 12
                                        color: theme.panel
                                        border.width: 1
                                        border.color: theme.fieldBorder
                                    }
                                }

                                Label {
                                    text: "Intervalos"
                                    color: theme.textSecondary
                                }

                                SpinBox {
                                    id: intervalBox
                                    from: 1
                                    to: 500
                                    value: 6
                                    editable: true
                                    Layout.fillWidth: true

                                    contentItem: TextInput {
                                        text: intervalBox.textFromValue(intervalBox.value, intervalBox.locale)
                                        color: theme.textPrimary
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        font.pixelSize: 14
                                        readOnly: !intervalBox.editable
                                        validator: intervalBox.validator
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }

                                    background: Rectangle {
                                        radius: 12
                                        color: theme.panel
                                        border.width: 1
                                        border.color: theme.fieldBorder
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                color: theme.textSecondary
                                text: "Ejemplo: minimo 0, maximo 300, intervalos 6 genera 7 puntos: 0, 50, 100, 150, 200, 250, 300."
                            }

                            AppButton {
                                Layout.fillWidth: true
                                theme: page.theme
                                text: "Generar puntos"
                                onClicked: controller.generatePoints(parseFloat(minimumField.text),
                                                                     parseFloat(maximumField.text),
                                                                     intervalBox.value)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 18
                    color: theme.field
                    border.width: 1
                    border.color: theme.fieldBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Label {
                            text: "Acciones"
                            color: theme.textPrimary
                            font.bold: true
                        }

                        AppButton {
                            Layout.fillWidth: true
                            theme: page.theme
                            text: "Analizar y abrir resultados"
                            enabled: controller.hasPoints
                            onClicked: {
                                controller.runAnalysis()
                                if (controller.hasResults)
                                    page.navigateToPage(2)
                            }
                        }

                        AppButton {
                            Layout.fillWidth: true
                            theme: page.theme
                            primary: false
                            text: "Limpiar puntos"
                            enabled: controller.hasPoints
                            onClicked: controller.clearPoints()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 18
                    color: theme.field
                    border.width: 1
                    border.color: theme.fieldBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        Label {
                            text: "Estado de la tabla"
                            color: theme.textPrimary
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: theme.textSecondary
                            text: controller.hasPoints
                                  ? controller.pointCount + " puntos, " + controller.missingYCount + " valores Y pendientes."
                                  : "Todavia no hay puntos cargados."
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

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
                    text: "Tabla de puntos"
                    color: theme.textPrimary
                    font.pixelSize: 22
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: theme.textSecondary
                    text: "X se muestra fijo. Y se puede editar en cada fila antes de correr el segmented fit."
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 14
                    color: theme.field
                    border.width: 1
                    border.color: theme.fieldBorder

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Label {
                            text: "#"
                            color: theme.textMuted
                            font.bold: true
                            Layout.preferredWidth: 48
                        }

                        Label {
                            text: "X"
                            color: theme.textSecondary
                            font.bold: true
                            Layout.preferredWidth: 180
                        }

                        Label {
                            text: "Y"
                            color: theme.textSecondary
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }
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
                        model: controller.pointModel
                        ScrollBar.vertical: ScrollBar { }

                        delegate: Rectangle {
                            id: pointRow
                            required property int index
                            required property string displayX
                            required property string displayY
                            required property bool validY

                            width: ListView.view ? ListView.view.width : 0
                            implicitHeight: 58
                            radius: 14
                            color: pointRow.index % 2 === 0 ? "#0d1728" : "#101b2f"
                            border.width: 1
                            border.color: pointRow.validY ? theme.border : theme.accentSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 48
                                    Layout.fillHeight: true
                                    radius: 10
                                    color: "#13253f"

                                    Label {
                                        anchors.centerIn: parent
                                        text: String(pointRow.index + 1)
                                        color: theme.textPrimary
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 180
                                    Layout.fillHeight: true
                                    radius: 10
                                    color: theme.panel
                                    border.width: 1
                                    border.color: theme.fieldBorder

                                    Label {
                                        anchors.centerIn: parent
                                        text: pointRow.displayX
                                        color: theme.textPrimary
                                    }
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: pointRow.displayY
                                    placeholderText: "Ingresa Y"
                                    color: theme.textPrimary
                                    selectByMouse: true
                                    onEditingFinished: controller.updatePointY(pointRow.index, text)

                                    background: Rectangle {
                                        radius: 10
                                        color: theme.panel
                                        border.width: 1
                                        border.color: pointRow.validY ? theme.fieldBorder : theme.accentSoft
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
