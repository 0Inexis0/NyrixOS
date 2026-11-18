import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

ShellRoot {
    id: root
    Wallpaper {}
    DynamicIsland { id: dynamicIsland }
    StatusMenus { id: statusMenus }
    SettingsWindow { id: settings; controller: root }
    function showSettings() { dynamicIsland.opened = false; root.opened = false; statusMenus.active = ""; settings.visible = true; root.refresh(); }

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    // One scan owner for popup and settings, so hidden views cannot cancel scans.
    Binding { target: root.wifiDevice; property: "scannerEnabled"; value: Networking.wifiEnabled && (statusMenus.active === "wifi" || (settings.visible && settings.category === "network")); when: !!root.wifiDevice; restoreMode: Binding.RestoreBindingOrValue }
    Binding { target: root.bluetoothAdapter; property: "discovering"; value: !!root.bluetoothAdapter && root.bluetoothAdapter.enabled && (statusMenus.active === "bluetooth" || (settings.visible && settings.category === "network")); when: !!root.bluetoothAdapter; restoreMode: Binding.RestoreBindingOrValue }
    property bool opened: false
    property string network: I18n.tr("Verbindung wird geprüft …")
    property bool hasWifi: false
    property bool wifiOn: false
    property real brightness: -1
    property string errorMessage: ""
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
    function toggle() { dynamicIsland.opened = false; statusMenus.active = ""; opened = !opened; errorMessage = ""; if (opened) refresh(); }
    function refresh() { if (!networkProbe.running) networkProbe.running = true; if (!brightnessProbe.running) brightnessProbe.running = true; }
    function execute(args) { if (!action.running) { errorMessage = ""; action.command = args; action.running = true; } }
    IpcHandler {
        target: "control"
        function toggle(): void { root.toggle(); }
        function settings(): void { root.showSettings(); }
        function shortcuts(): void { settings.category = "shortcuts"; root.showSettings(); }
        function island(): void { root.opened = false; statusMenus.active = ""; dynamicIsland.opened = !dynamicIsland.opened; }
        function close(): void { dynamicIsland.opened = false; root.opened = false; statusMenus.active = ""; }
        function menu(kind: string): void { dynamicIsland.opened = false; root.opened = false; statusMenus.toggle(kind); }
    }
    Process {
        id: action
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.errorMessage = text.trim().slice(0, 120); } }
        onExited: (exitCode, exitStatus) => { if (exitCode !== 0 && !root.errorMessage) root.errorMessage = I18n.tr("Aktion konnte nicht ausgeführt werden."); root.refresh(); }
    }
    Process {
        id: networkProbe
        command: ["sh", "-c", "LC_ALL=C nmcli -t -f TYPE,STATE device; printf '\\nRADIO='; LC_ALL=C nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.hasWifi = lines.some(l => l.startsWith("wifi:"));
                root.wifiOn = lines.some(l => l === "RADIO=enabled");
                root.network = lines.some(l => l === "wifi:connected") ? I18n.tr("WLAN verbunden") : lines.some(l => l === "ethernet:connected") ? I18n.tr("LAN verbunden") : I18n.tr("Nicht verbunden");
            }
        }
    }
    Process {
        id: brightnessProbe
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -d \"$d\" ] || continue; brightnessctl -c backlight -m; break; done"]
        stdout: StdioCollector { onStreamFinished: { const fields = text.trim().split(","); root.brightness = fields.length >= 4 ? parseInt(fields[3]) / 100 : -1; } }
    }
    Timer { interval: 5000; running: root.opened || settings.visible; repeat: true; onTriggered: root.refresh() }
    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; right: true }
        margins { top: 54; right: 12 }
        implicitWidth: 360
        implicitHeight: content.implicitHeight + 32
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "nyrix-control-center"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        Rectangle {
            anchors.fill: parent
            color: "#262626"; radius: 18
            FocusScope {
                anchors.fill: parent; focus: true
                Keys.onEscapePressed: { root.opened = false; }
                ColumnLayout {
                    id: content
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 3
                            Text { text: I18n.tr("Kontrollzentrum"); color: "#ededed"; font.pixelSize: 17; font.bold: true }
                        }
                        Item { Layout.fillWidth: true }
                        ActionButton { text: "×"; compact: true; implicitWidth: 30; implicitHeight: 30; onClicked: root.opened = false; Accessible.name: I18n.tr("Schließen") }
                    }
                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: radios.implicitHeight + 24
                        color: "#2e2e2e"; radius: 14
                        ColumnLayout {
                            id: radios
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 12
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: radios.width
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 3
                                    Text { text: I18n.tr("WLAN"); color: "#ededed"; font.pixelSize: 13 }
                                    Text { text: !root.hasWifi ? I18n.tr("Kein Adapter") : Networking.wifiEnabled ? I18n.tr("Eingeschaltet") : I18n.tr("Ausgeschaltet"); color: "#999999"; font.pixelSize: 11 }
                                }
                                ToggleSwitch { checked: root.hasWifi && Networking.wifiEnabled; enabled: root.hasWifi && Networking.wifiHardwareEnabled; onToggled: Networking.wifiEnabled = checked; Accessible.name: I18n.tr("WLAN einschalten") }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: radios.width
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 3
                                    Text { text: "Bluetooth"; color: "#ededed"; font.pixelSize: 13 }
                                    Text { text: !Bluetooth.defaultAdapter ? I18n.tr("Kein Adapter") : Bluetooth.defaultAdapter.enabled ? I18n.tr("Eingeschaltet") : I18n.tr("Ausgeschaltet"); color: "#999999"; font.pixelSize: 11 }
                                }
                                ToggleSwitch { checked: !!Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled; enabled: !!Bluetooth.defaultAdapter; onToggled: Bluetooth.defaultAdapter.enabled = checked; Accessible.name: I18n.tr("Bluetooth einschalten") }
                            }

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: levels.implicitHeight + 24
                        color: "#2e2e2e"; radius: 14
                        ColumnLayout {
                            id: levels
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 10
                            RowLayout {
                                Layout.fillWidth: true; spacing: 10
                                Item {
                                    Layout.preferredWidth: 34; Layout.preferredHeight: 34
                                    Image {
                                        anchors.centerIn: parent; width: 22; height: 22
                                        source: Qt.resolvedUrl("icons/brightness.svg")
                                        opacity: root.brightness >= 0 ? 1 : 0.3
                                    }
                                    HoverHandler { id: brightnessHover }
                                    ToolTip.visible: brightnessHover.hovered
                                    ToolTip.text: root.brightness >= 0 ? I18n.tr("Helligkeit") : I18n.tr("Nicht verfügbar")
                                }
                                LevelSlider {
                                    Layout.fillWidth: true; enabled: root.brightness >= 0; from: 0.05; to: 1
                                    Accessible.name: I18n.tr("Helligkeit")
                                    value: root.brightness >= 0 ? root.brightness : 0.05
                                    onPressedChanged: { if (!pressed && enabled) root.execute(["brightnessctl", "-c", "backlight", "set", Math.round(value * 100) + "%"]); }
                                }
                            }
                            StatusContent { Layout.fillWidth: true; active: "volume" }
                        }
                    }
                    ActionButton {
                        Layout.fillWidth: true; text: I18n.tr("Einstellungen")
                        onClicked: root.showSettings()
                    }
                    Text { visible: root.errorMessage !== ""; text: root.errorMessage; color: "#ef9fa9"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
        }
    }
}
