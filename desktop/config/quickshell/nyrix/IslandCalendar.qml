import QtQuick
import QtQuick.Layouts
ColumnLayout {
    id: calendar
    property date now: new Date()
    property date month: new Date(now.getFullYear(),now.getMonth(),1)
    readonly property var locale: Qt.locale(I18n.language === "de" ? "de_DE" : "en_US")
    readonly property int offset: (month.getDay()+6)%7
    readonly property int days: new Date(month.getFullYear(),month.getMonth()+1,0).getDate()
    Layout.fillWidth: true; spacing: 12
    function shift(delta) { month = new Date(month.getFullYear(),month.getMonth()+delta,1); }
    Timer { interval: 30000; running: calendar.visible; repeat: true; onTriggered: calendar.now = new Date() }
    RowLayout {
        Layout.fillWidth: true
        Text { text: calendar.month.toLocaleDateString(calendar.locale,"MMMM yyyy"); color: "#f0f0f2"; font.pixelSize: 16; font.weight: Font.DemiBold; Layout.fillWidth: true }
        SettingsButton { text: "‹"; implicitWidth: 30; implicitHeight: 30; leftPadding: 0; rightPadding: 0; onClicked: calendar.shift(-1) }
        SettingsButton { text: I18n.language === "de" ? "Heute" : "Today"; implicitHeight: 30; onClicked: calendar.month = new Date(calendar.now.getFullYear(),calendar.now.getMonth(),1) }
        SettingsButton { text: "›"; implicitWidth: 30; implicitHeight: 30; leftPadding: 0; rightPadding: 0; onClicked: calendar.shift(1) }
    }
    GridLayout {
        columns: 7; rowSpacing: 5; columnSpacing: 5; Layout.fillWidth: true
        Repeater {
            model: I18n.language === "de" ? ["Mo","Di","Mi","Do","Fr","Sa","So"] : ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
            delegate: Text { required property string modelData; text: modelData; color: "#858590"; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; Layout.preferredHeight: 25 }
        }
        Repeater {
            model: 42
            delegate: Rectangle {
                required property int index
                readonly property int day: index-calendar.offset+1
                readonly property bool valid: day>0 && day<=calendar.days
                readonly property bool today: valid && day === calendar.now.getDate() && calendar.month.getMonth() === calendar.now.getMonth() && calendar.month.getFullYear() === calendar.now.getFullYear()
                Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 24
                radius: 10; color: today ? "#ade6d1" : valid ? "#303034" : "transparent"
                Text { anchors.centerIn: parent; text: parent.valid ? parent.day : ""; color: parent.today ? "#1d3028" : "#c7c7d0"; font.pixelSize: 12; font.bold: parent.today }
            }
        }
    }
    Text { text: I18n.language === "de" ? "Lokaler Kalender · keine Terminkonten verbunden" : "Local calendar · no event accounts connected"; color: "#888893"; font.pixelSize: 11 }
}
