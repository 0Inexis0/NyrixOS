import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

ColumnLayout {
    id: menu
    spacing: 12
    signal dismissRequested()
    property string active: ""
    property string message: ""
    property var selectedNetwork: null
    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var sink: Pipewire.defaultAudioSink
    property real lastAudibleVolume: 0.5
    readonly property bool silent: !sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0
    Connections {
        target: menu.sink ? menu.sink.audio : null
        function onVolumeChanged() { if (menu.sink.audio.volume > 0) menu.lastAudibleVolume = menu.sink.audio.volume; }
    }
    PwObjectTracker { objects: menu.sink ? [menu.sink] : [] }
    onActiveChanged: { message = ""; selectedNetwork = null; password.clear(); }
    Connections {
        target: menu.selectedNetwork
        function onConnectionFailed(reason) { menu.message = I18n.tr("Verbindung fehlgeschlagen: ") + ConnectionFailReason.toString(reason); }
    }
                    RowLayout {
                        visible: menu.active === "volume"
                        Layout.fillWidth: true; spacing: 10
                        Button {
                            id: muteIcon
                            Layout.preferredWidth: 34; Layout.preferredHeight: 34
                            enabled: !!(menu.sink && menu.sink.audio)
                            hoverEnabled: true
                            Accessible.name: menu.silent ? I18n.tr("Ton an") : I18n.tr("Stumm")
                            ToolTip.visible: hovered
                            ToolTip.text: Accessible.name
                            opacity: enabled ? 1 : 0.3
                            background: Rectangle { radius: 10; color: muteIcon.down ? "#484848" : muteIcon.hovered ? "#393939" : "transparent" }
                            contentItem: Item {
                                Image {
                                    anchors.centerIn: parent; width: 22; height: 22
                                    source: Qt.resolvedUrl("icons/" + (menu.silent ? "volume-x.svg" : "volume-2.svg"))
                                }
                            }
                            onClicked: {
                                const audio = menu.sink.audio;
                                if (audio.volume <= 0) { audio.volume = menu.lastAudibleVolume; audio.muted = false; }
                                else audio.muted = !audio.muted;
                            }
                        }
                        LevelSlider {
                            Layout.fillWidth: true
                            enabled: !!(menu.sink && menu.sink.audio)
                            value: menu.sink && menu.sink.audio ? menu.sink.audio.volume : 0
                            onMoved: {
                                if (menu.sink && menu.sink.audio) {
                                    if (menu.sink.audio.volume > 0) menu.lastAudibleVolume = menu.sink.audio.volume;
                                    menu.sink.audio.volume = value;
                                    if (value > 0) menu.sink.audio.muted = false;
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: menu.active === "wifi"; Layout.fillWidth: true; spacing: 10
                        RowLayout {
                            Text { Layout.fillWidth: true; text: !menu.wifi ? I18n.tr("Kein WLAN-Adapter") : !Networking.wifiHardwareEnabled ? I18n.tr("Am Gerät gesperrt") : Networking.wifiEnabled ? I18n.tr("Eingeschaltet") : I18n.tr("Ausgeschaltet"); color: "#b4b4b4" }
                            ToggleSwitch { checked: !!menu.wifi && Networking.wifiEnabled; enabled: !!menu.wifi && Networking.wifiHardwareEnabled; onToggled: Networking.wifiEnabled = checked; Accessible.name: I18n.tr("WLAN einschalten") }
                        }
                        Text { visible: !!menu.wifi && Networking.wifiEnabled && menu.wifi.networks.values.length === 0; text: I18n.tr("Suche nach Netzwerken …"); color: "#999999" }
                        ScrollView {
                            visible: !!menu.wifi && Networking.wifiEnabled
                            Layout.fillWidth: true; Layout.preferredHeight: Math.min(wifiList.implicitHeight, 240); clip: true
                            ColumnLayout {
                                id: wifiList; width: parent.width; spacing: 6
                                Repeater {
                                    model: menu.wifi ? menu.wifi.networks : null
                                    delegate: ActionButton {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        text: (modelData.connected ? "✓ " : "") + (modelData.name || I18n.tr("Verstecktes Netzwerk")) + (modelData.stateChanging ? " …" : "")
                                        enabled: !modelData.stateChanging
                                        onClicked: {
                                            menu.selectedNetwork = modelData; menu.message = ""; password.clear();
                                            if (modelData.connected) modelData.disconnect();
                                            else if (modelData.known || modelData.security === WifiSecurityType.Open || modelData.security === WifiSecurityType.Owe) modelData.connect();
                                            else if (![WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(modelData.security)) menu.message = I18n.tr("Für dieses Netzwerk bitte die erweiterte Einrichtung verwenden.");
                                            else password.forceActiveFocus();
                                        }
                                    }
                                }
                            }
                        }
                        ColumnLayout {
                            visible: !!menu.selectedNetwork && !menu.selectedNetwork.connected && !menu.selectedNetwork.known && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(menu.selectedNetwork.security)
                            Layout.fillWidth: true
                            TextField { id: password; Layout.fillWidth: true; placeholderText: I18n.tr("WLAN-Passwort"); echoMode: TextInput.Password; onAccepted: connectButton.clicked() }
                            ActionButton { id: connectButton; text: I18n.tr("Verbinden"); Layout.fillWidth: true; enabled: password.text.length > 0 && !!menu.selectedNetwork && !menu.selectedNetwork.stateChanging; onClicked: { if (enabled) { menu.selectedNetwork.connectWithPsk(password.text); password.clear(); } } }
                        }
                        ActionButton { text: I18n.tr("Erweiterte Einrichtung"); Layout.fillWidth: true; onClicked: { Quickshell.execDetached(["foot", "nmtui"]); menu.dismissRequested(); } }
                    }
                    ColumnLayout {
                        visible: menu.active === "bluetooth"; Layout.fillWidth: true; spacing: 10
                        RowLayout {
                            Text { Layout.fillWidth: true; text: !menu.adapter ? I18n.tr("Kein Bluetooth-Adapter") : menu.adapter.enabled ? I18n.tr("Eingeschaltet") : I18n.tr("Ausgeschaltet"); color: "#b4b4b4" }
                            ToggleSwitch { checked: !!menu.adapter && menu.adapter.enabled; enabled: !!menu.adapter; onToggled: menu.adapter.enabled = checked; Accessible.name: I18n.tr("Bluetooth einschalten") }
                        }
                        Text { visible: !!menu.adapter && menu.adapter.enabled && menu.adapter.devices.values.length === 0; text: I18n.tr("Suche nach Geräten …"); color: "#999999" }
                        ScrollView {
                            visible: !!menu.adapter && menu.adapter.enabled
                            Layout.fillWidth: true; Layout.preferredHeight: Math.min(btList.implicitHeight, 240); clip: true
                            ColumnLayout {
                                id: btList; width: parent.width; spacing: 6
                                Repeater {
                                    model: menu.adapter ? menu.adapter.devices : null
                                    delegate: ActionButton {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        text: (modelData.connected ? "✓ " : "") + (modelData.name || modelData.address) + (modelData.pairing ? " …" : "")
                                        enabled: !modelData.pairing
                                        onClicked: {
                                            if (modelData.connected) modelData.disconnect();
                                            else if (modelData.paired) modelData.connect();
                                            else { Quickshell.execDetached(["foot", "nyrix-bluetooth-pair", modelData.address]); menu.dismissRequested(); }
                                        }
                                    }
                                }
                            }
                        }
                        Text { visible: !!menu.adapter && menu.adapter.enabled; text: I18n.tr("Gerät wählen zum Verbinden. Neue Geräte öffnen bei Bedarf einen Kopplungsdialog."); color: "#999999"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    }
                    ColumnLayout {
                        visible: menu.active === "network"; Layout.fillWidth: true
                        Repeater {
                            model: Networking.devices
                            delegate: Text {
                                required property var modelData
                                Layout.fillWidth: true; textFormat: Text.PlainText; wrapMode: Text.WordWrap; color: "#dedede"
                                text: modelData.name + " · " + (modelData.connected ? I18n.tr("Verbunden") : I18n.tr("Nicht verbunden"))
                            }
                        }
                    }
                    Text { visible: menu.message !== ""; text: menu.message; textFormat: Text.PlainText; color: "#ef9fa9"; wrapMode: Text.WordWrap; Layout.fillWidth: true; font.pixelSize: 11 }
}
