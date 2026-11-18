import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

Scope {
    id: menu
    property string active: ""
    function toggle(kind) { active = active === kind ? "" : kind; }
    PanelWindow {
        id: popup
        visible: menu.active !== ""
        anchors { top: true; right: true }
        margins { top: 54; right: 12 }
        implicitWidth: 320
        implicitHeight: body.implicitHeight + 32
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "nyrix-status-menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        Rectangle {
            anchors.fill: parent
            color: "#262626"; radius: 18
            FocusScope {
                anchors.fill: parent; focus: true
                Keys.onEscapePressed: menu.active = ""
                ColumnLayout {
                    id: body
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ({wifi:I18n.tr("WLAN"), bluetooth:"Bluetooth", volume:I18n.tr("Lautstärke"), network:I18n.tr("Netzwerk")})[menu.active] ?? ""; color: "#ededed"; font.pixelSize: 16; font.bold: true }
                        Item { Layout.fillWidth: true }
                        ActionButton { text: "×"; compact: true; implicitWidth: 30; implicitHeight: 30; onClicked: menu.active = ""; Accessible.name: I18n.tr("Menü schließen") }
                    }
                    StatusContent { Layout.fillWidth: true; active: menu.active; onDismissRequested: menu.active = "" }
                }
            }
        }
    }
}
