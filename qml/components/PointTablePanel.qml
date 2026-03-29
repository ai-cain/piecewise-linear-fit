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
            text: "Points Table"
            color: theme.textPrimary
            font.pixelSize: 22
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: theme.textSecondary
            text: "X is fixed. Edit Y values row by row before running the analysis."
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
                            placeholderText: "Enter Y"
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
