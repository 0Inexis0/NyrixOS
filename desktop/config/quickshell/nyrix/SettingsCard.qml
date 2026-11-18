import QtQuick
import QtQuick.Layouts
Rectangle {
    id: card
    default property alias content: body.data
    property string heading: ""
    property string icon: ""
    color: "#27272b"; radius: 16
    implicitHeight: body.implicitHeight + 40
    data: ColumnLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
        spacing: 16
        RowLayout {
            visible: card.heading !== ""
            Layout.fillWidth: true; spacing: 10
            Image { visible: card.icon !== ""; source: card.icon; Layout.preferredWidth: 20; Layout.preferredHeight: 20; opacity: 0.8 }
            Text { text: card.heading; color: "#f0f0f2"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        }
    }
}
