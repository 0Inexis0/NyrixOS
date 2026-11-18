import QtQuick
import QtQuick.Layouts
Rectangle {
    id: meter
    property string label: ""
    property string value: "—"
    property string detail: ""
    property real percent: -1
    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + 28
    color: "#303034"; radius: 13
    ColumnLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Text { text: meter.label; color: "#a3a3ae"; font.pixelSize: 12; Layout.fillWidth: true }
            Text { text: meter.value; color: "#ededf0"; font.pixelSize: 15; font.weight: Font.DemiBold }
        }
        Rectangle {
            visible: meter.percent >= 0
            Layout.fillWidth: true; implicitHeight: 5; radius: 3; color: "#46464d"
            Rectangle { width: parent.width*Math.min(100,Math.max(0,meter.percent))/100; height: parent.height; radius: 3; color: meter.percent > 90 ? "#edac9e" : "#ade6d1"; Behavior on width { NumberAnimation { duration: 220 } } }
        }
        Text { visible: meter.detail !== ""; text: meter.detail; textFormat: Text.PlainText; color: "#888893"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }
}
