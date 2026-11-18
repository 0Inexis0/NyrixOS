import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Switch {
    id: control
    Layout.fillWidth: false
    Layout.maximumWidth: 46
    Layout.minimumWidth: 46
    implicitWidth: 46
    implicitHeight: 30
    padding: 0
    hoverEnabled: true
    opacity: enabled ? 1 : 0.38
    indicator: Rectangle {
        x: 0; y: (control.height - height) / 2
        width: 46; height: 26; radius: 13
        color: control.checked ? "#a7ede1" : control.hovered ? "#505050" : "#444444"
        border.width: control.activeFocus ? 1 : 0
        border.color: "#ededed"
        Behavior on color { ColorAnimation { duration: 120 } }
        Rectangle {
            x: control.checked ? 23 : 3; y: 3
            width: 20; height: 20; radius: 10
            color: control.checked ? "#243330" : "#dedede"
            Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }
    }
    contentItem: Item {}
    background: Item {}
}
