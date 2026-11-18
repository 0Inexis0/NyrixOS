import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
ColumnLayout {
    id: shortcuts
    property bool active: false
    property var rows: []
    property string message: ""
    property bool failed: false
    spacing: 12
    function invoke(args) { if (task.running) return; message = ""; task.command = ["nyrix-shortcuts"].concat(args); task.running = true; }
    onActiveChanged: { if (active) invoke(["list"]); }
    Text { text: I18n.tr("Kombination ändern, dann speichern. Super ist die Windows-Taste. Änderungen gelten sofort."); Layout.fillWidth: true; wrapMode: Text.WordWrap; color: "#aaaaaa"; font.pixelSize: 12 }
    Text { visible: shortcuts.message !== ""; text: shortcuts.message; textFormat: Text.PlainText; wrapMode: Text.WrapAnywhere; Layout.fillWidth: true; color: shortcuts.failed ? "#ef9fa9" : "#a7ede1" }
    Repeater {
        model: shortcuts.rows
        delegate: SettingsCard {
            required property var modelData
            Layout.fillWidth: true
            Text { text: I18n.language === "en" ? modelData.en : modelData.de; color: "#ededed"; font.pixelSize: 13; Layout.fillWidth: true; wrapMode: Text.WordWrap }
            RowLayout {
                Layout.fillWidth: true; spacing: 8
                TextField {
                    id: chord
                    text: modelData.current
                    Layout.fillWidth: true; Layout.minimumWidth: 100; implicitHeight: 38; leftPadding: 12; rightPadding: 12
                    color: "#ededed"; font.pixelSize: 12; selectByMouse: true
                    background: Rectangle { radius: 9; color: "#1e1e21"; border.width: chord.activeFocus ? 1 : 0; border.color: "#a7ede1" }
                    onAccepted: shortcuts.invoke(["set", modelData.id, text])
                }
                SettingsButton { text: I18n.tr("Speichern"); implicitHeight: 34; enabled: !task.running && chord.text !== modelData.current; onClicked: shortcuts.invoke(["set", modelData.id, chord.text]) }
                SettingsButton { text: I18n.tr("Standard"); implicitHeight: 34; enabled: !task.running && modelData.current !== modelData.chord; onClicked: shortcuts.invoke(["set", modelData.id, modelData.chord]) }
            }
        }
    }
    Process {
        id: task
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    shortcuts.failed = !result.ok;
                    if (result.ok) { shortcuts.rows = result.rows; shortcuts.message = task.command[1] === "set" ? I18n.tr("Gespeichert") : ""; }
                    else shortcuts.message = result.error;
                } catch (e) { shortcuts.failed = true; shortcuts.message = String(e); }
            }
        }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) { shortcuts.failed = true; shortcuts.message = text.trim(); } } }
    }
}
