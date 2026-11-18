import QtQuick
import QtQuick.Controls
Button {
    id: button
    property bool primary: false
    implicitHeight: 38
    leftPadding: 16; rightPadding: 16
    hoverEnabled: true
    opacity: enabled ? 1 : 0.35
    background: Rectangle {
        radius: 10
        color: button.primary ? (button.down ? "#83bda9" : button.hovered ? "#c3f1df" : "#ade6d1") : (button.down ? "#45454b" : button.hovered ? "#3e3e44" : "#343439")
        border.width: button.visualFocus ? 1 : 0; border.color: "#ade6d1"
        Behavior on color { ColorAnimation { duration: 120 } }
    }
    contentItem: Text { text: button.text; font.pixelSize: 12; font.weight: Font.DemiBold; color: button.primary ? "#1c3028" : "#dedee3"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
}
