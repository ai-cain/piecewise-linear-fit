pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tile
    required property var theme
    property string label: ""
    property string value: ""
    property string note: ""
    property color accentColor: theme.accent

    implicitHeight: 94
    radius: 18
    color: theme.panelAlt
    border.width: 1
    border.color: theme.border

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 4
        radius: 2
        color: tile.accentColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        Label {
            text: tile.label
            color: theme.textMuted
            font.pixelSize: 11
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        Label {
            text: tile.value
            color: theme.textPrimary
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: tile.note
            color: theme.textSecondary
            font.pixelSize: 12
        }
    }
}
