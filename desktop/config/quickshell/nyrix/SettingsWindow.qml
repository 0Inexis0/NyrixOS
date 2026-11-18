import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: settings
    required property var controller
    property string category: "network"
    property string profileName: Quickshell.env("USER") || I18n.tr("Benutzer")
    property string avatarPath: ""
    readonly property var categories: [
        {key: "network", icon: "wifi.svg", title: I18n.tr("Netzwerk & Bluetooth"), subtitle: I18n.tr("Verbindungen und Geräte")},
        {key: "display", icon: "display.svg", title: "Display", subtitle: I18n.tr("Helligkeit deines Bildschirms")},
        {key: "personal", icon: "personal.svg", title: I18n.tr("Personalisieren"), subtitle: I18n.tr("Sprache und Erscheinungsbild")},
        {key: "shortcuts", icon: "shortcuts.svg", title: "Shortcuts", subtitle: I18n.tr("Tastenkürzel ansehen und bearbeiten")},
        {key: "updates", icon: "updates.svg", title: "Updates", subtitle: I18n.tr("NyrixOS und Arch aktuell halten")}
    ]
    readonly property var page: categories.find(c => c.key === category) || categories[0]
    visible: false
    title: I18n.tr("NyrixOS Einstellungen")
    implicitWidth: 940; implicitHeight: 650
    minimumSize: Qt.size(780, 520)
    color: "#1e1e21"
    onCategoryChanged: pageScroll.contentItem.contentY = 0
    onVisibleChanged: { if (visible && !profileProbe.running) profileProbe.running = true; }
    Process {
        id: profileProbe
        command: ["sh", "-c", "u=$(id -un); n=$(getent passwd \"$u\" | cut -d: -f5 | cut -d, -f1); printf '%s\\n' \"${n:-$u}\"; if [ -r \"$HOME/.face\" ]; then printf '%s\\n' \"$HOME/.face\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                settings.profileName = lines[0] || Quickshell.env("USER") || I18n.tr("Benutzer");
                settings.avatarPath = lines[1] ? "file://" + lines[1] : "";
            }
        }
    }

    RowLayout {
        anchors.fill: parent; spacing: 0
        Rectangle {
            Layout.preferredWidth: 232; Layout.fillHeight: true
            color: "#19191c"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 6
                Text { text: "NYRIXOS"; color: "#86868f"; font.pixelSize: 10; font.letterSpacing: 2.5; Layout.leftMargin: 12; Layout.topMargin: 14; Layout.bottomMargin: 22 }
                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 8; Layout.rightMargin: 8; spacing: 12
                    Rectangle {
                        Layout.preferredWidth: 44; Layout.preferredHeight: 44
                        radius: 16; color: "#343c38"
                        Image { id: avatar; anchors.fill: parent; anchors.margins: 5; source: settings.avatarPath; fillMode: Image.PreserveAspectFit; visible: status === Image.Ready }
                        Text { anchors.centerIn: parent; visible: avatar.status !== Image.Ready; text: settings.profileName.slice(0,1).toUpperCase(); color: "#ade6d1"; font.pixelSize: 21; font.weight: Font.DemiBold }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4
                        Text { text: settings.profileName; textFormat: Text.PlainText; color: "#f0f0f2"; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                        Text { text: I18n.tr("Lokales Profil"); color: "#82828c"; font.pixelSize: 11 }
                    }
                }
                Item { Layout.preferredHeight: 28 }
                Repeater {
                    model: settings.categories
                    delegate: Button {
                        id: nav
                        required property var modelData
                        readonly property bool selected: settings.category === modelData.key
                        Layout.fillWidth: true; Layout.preferredHeight: 48
                        hoverEnabled: true
                        onClicked: settings.category = modelData.key
                        background: Rectangle {
                            radius: 12; color: nav.selected ? "#303d36" : nav.hovered ? "#27272c" : "transparent"
                            Behavior on color { ColorAnimation { duration: 130 } }
                        }
                        contentItem: RowLayout {
                            spacing: 12
                            Image { Layout.leftMargin: 12; Layout.preferredWidth: 18; Layout.preferredHeight: 18; source: Qt.resolvedUrl("icons/"+modelData.icon); opacity: nav.selected ? 1 : 0.65 }
                            Text { text: modelData.title; color: nav.selected ? "#bcebd8" : "#b1b1bb"; font.pixelSize: 12; font.weight: nav.selected ? Font.DemiBold : Font.Normal; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                Text { text: "Arch + Hyprland"; color: "#63636e"; font.pixelSize: 10; Layout.leftMargin: 12; Layout.bottomMargin: 10 }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 30; spacing: 24
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 8
                    Text { text: I18n.tr("Einstellungen"); color: "#7e7e88"; font.pixelSize: 11 }
                    Text { text: settings.page.title; color: "#f2f2f4"; font.pixelSize: 28; font.weight: Font.DemiBold; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    Text { text: settings.page.subtitle; color: "#92929e"; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    TapHandler { onPressedChanged: { if (pressed) settings.startSystemMove(); } }
                }
                SettingsButton { text: "×"; Layout.alignment: Qt.AlignTop; implicitWidth: 34; implicitHeight: 34; leftPadding: 0; rightPadding: 0; Accessible.name: I18n.tr("Einstellungen schließen"); onClicked: settings.visible = false }
            }
            ScrollView {
                id: pageScroll
                Layout.fillWidth: true; Layout.fillHeight: true
                contentWidth: availableWidth; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: pageScroll.availableWidth; spacing: 14
                    ColumnLayout {
                        visible: settings.category === "network"; Layout.fillWidth: true; spacing: 14
                        SettingsCard {
                            Layout.fillWidth: true; heading: I18n.tr("WLAN"); icon: Qt.resolvedUrl("icons/wifi.svg")
                            StatusContent { Layout.fillWidth: true; active: settings.visible && settings.category === "network" ? "wifi" : "" }
                        }
                        SettingsCard {
                            Layout.fillWidth: true; heading: "Bluetooth"; icon: Qt.resolvedUrl("icons/bluetooth.svg")
                            StatusContent { Layout.fillWidth: true; active: settings.visible && settings.category === "network" ? "bluetooth" : "" }
                        }
                        SettingsCard {
                            Layout.fillWidth: true; heading: I18n.tr("Netzwerk"); icon: Qt.resolvedUrl("icons/ethernet-port.svg")
                            StatusContent { Layout.fillWidth: true; active: settings.visible && settings.category === "network" ? "network" : "" }
                        }
                    }
                    ColumnLayout {
                        visible: settings.category === "personal"; Layout.fillWidth: true; spacing: 14
                        SettingsCard {
                            Layout.fillWidth: true; heading: I18n.tr("Sprache")
                            RowLayout {
                                Layout.fillWidth: true; spacing: 10
                                SettingsButton { Layout.fillWidth: true; text: "Deutsch"; primary: I18n.language === "de"; onClicked: I18n.setLanguage("de") }
                                SettingsButton { Layout.fillWidth: true; text: "English"; primary: I18n.language === "en"; onClicked: I18n.setLanguage("en") }
                            }
                            Text { text: I18n.tr("Andere Programme übernehmen die Sprache nach einer neuen Anmeldung. Tastaturbelegung bleibt unverändert."); color: "#92929e"; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                        SettingsCard {
                            Layout.fillWidth: true; heading: "NyrixOS Desktop"
                            Image { source: Qt.resolvedUrl("wallpaper.png"); Layout.fillWidth: true; Layout.preferredHeight: 130; fillMode: Image.PreserveAspectCrop; clip: true }
                        }
                    }
                    ShortcutsPage { visible: settings.category === "shortcuts"; active: settings.visible && visible; Layout.fillWidth: true }
                    UpdatesPage { visible: settings.category === "updates"; active: settings.visible && visible; Layout.fillWidth: true }
                    SettingsCard {
                        visible: settings.category === "display"; Layout.fillWidth: true
                        heading: I18n.tr("Helligkeit"); icon: Qt.resolvedUrl("icons/brightness.svg")
                        LevelSlider {
                            Layout.fillWidth: true; from: 0.05; to: 1
                            enabled: settings.controller.brightness >= 0; Accessible.name: I18n.tr("Helligkeit")
                            value: enabled ? settings.controller.brightness : 0.05
                            onPressedChanged: { if (!pressed && enabled) settings.controller.execute(["brightnessctl", "-c", "backlight", "set", Math.round(value * 100) + "%"]); }
                        }
                        Text { visible: settings.controller.brightness < 0; text: I18n.tr("Dieser Bildschirm stellt keine regelbare Hintergrundbeleuchtung bereit."); color: "#92929e"; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    }
                    Text { visible: settings.category === "display" && settings.controller.errorMessage !== ""; text: settings.controller.errorMessage; color: "#ef9fa9"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
        }
    }
}
