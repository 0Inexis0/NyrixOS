import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
ColumnLayout {
    id: updates
    property bool active: false
    property string report: ""
    spacing: 14
    onActiveChanged: { if (active && !probe.running) probe.running = true; }
    SettingsCard {
        Layout.fillWidth: true; heading: "NyrixOS + Arch Linux"; icon: Qt.resolvedUrl("icons/updates.svg")
        Text { text: I18n.tr("Quelle: GitHub · 0Inexis0/NyrixOS · main"); color: "#92929e"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Text { text: I18n.tr("Aktualisiert NyrixOS und alle Arch-Pakete. Bestätigung und Administratorpasswort erfolgen im Terminal. Eigene Konfigurationen werden vorher gesichert."); color: "#b9b9c3"; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Flow {
            Layout.fillWidth: true; spacing: 10
            SettingsButton { text: I18n.tr("Nach Updates suchen"); enabled: !probe.running; onClicked: probe.running = true }
            SettingsButton { text: I18n.tr("Aktualisieren"); primary: true; onClicked: Quickshell.execDetached(["foot", "--title=NyrixOS Update", "nyrix-update-terminal"]) }
        }
    }
    SettingsCard {
        Layout.fillWidth: true; heading: I18n.tr("Changelog / Status")
        Text { text: probe.running ? I18n.tr("Wird geprüft …") : updates.report; textFormat: Text.PlainText; color: "#a8a8b3"; font.pixelSize: 12; lineHeight: 1.3; wrapMode: Text.WrapAnywhere; Layout.fillWidth: true }
    }
    Connections { target: I18n; function onLanguageChanged() { if (updates.active && !probe.running) probe.running = true; } }
    Process {
        id: probe
        command: ["nyrix-update-check", I18n.language]
        stdout: StdioCollector { onStreamFinished: updates.report = text.trim() }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) updates.report = text.trim(); } }
    }
}
