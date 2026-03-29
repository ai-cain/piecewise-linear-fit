pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Button {
    id: control
    required property var theme
    property bool primary: true

    implicitHeight: 46
    padding: 0

    contentItem: Label {
        text: control.text
        color: control.primary ? "#08111f" : control.theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
        font.bold: true
    }

    background: Rectangle {
        radius: 14
        color: !control.enabled
               ? "#334055"
               : (control.down
                  ? (control.primary ? control.theme.accentStrong : "#15243a")
                  : (control.primary ? control.theme.accent : control.theme.field))
        border.width: 1
        border.color: control.primary ? control.theme.accentSoft : control.theme.fieldBorder
    }
}
