import QtQuick
import QtQuick.Controls
Button {
    id: control
    property bool accent: false
    property bool compact: false
    implicitHeight: 40
    font.family: "DejaVu Sans"
    font.pixelSize: 12
    opacity: enabled ? 1 : 0.4
    background: Rectangle {
        radius: control.compact ? 10 : 12
        color: control.down ? "#484848" : control.hovered ? "#414141" : control.accent ? "#a7ede1" : "#343434"
        border.color: control.activeFocus ? "#a7ede1" : "transparent"
    }
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        elide: Text.ElideRight
        font: control.font
        color: control.accent && !control.hovered && !control.down ? "#14262a" : "#ededed"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
