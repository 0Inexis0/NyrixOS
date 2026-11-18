import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: island
    property bool opened: false
    property string tab: "dashboard"
    property date now: new Date()
    property var stats: ({})
    property var weather: ({})
    property var limits: ({})
    property var locations: []
    property string error: ""
    function tr(de,en) { return I18n.language === "de" ? de : en; }
    function pct(v) { return v === undefined || v === null ? "—" : Math.round(v) + "%"; }
    function temp(v) { return v === undefined || v === null ? "—" : Math.round(v) + "°C"; }
    function gib(v) { return v === undefined ? "—" : (v/1073741824).toFixed(1) + " GiB"; }
    function refresh() {
        error = "";
        if ((tab === "performance" || tab === "dashboard") && !metrics.running) metrics.running = true;
        if (tab === "ai" && !aiProbe.running) aiProbe.running = true;
        if (tab === "weather" && !weatherProbe.running) { weatherProbe.command = ["nyrix-island-data","weather"]; weatherProbe.running = true; }
    }
    function condition(code) {
        if (code === undefined || code === null) return "—";
        if (code === 0) return tr("Klar","Clear");
        if (code <= 3) return tr("Bewölkt","Cloudy");
        if (code <= 48) return tr("Nebel","Fog");
        if (code <= 67) return tr("Regen","Rain");
        if (code <= 77) return tr("Schnee","Snow");
        if (code <= 82) return tr("Schauer","Showers");
        if (code <= 86) return tr("Schneeschauer","Snow showers");
        return tr("Gewitter","Thunderstorms");
    }
    function resetText(w) { return w ? tr("Reset: ","Resets: ") + new Date(w.reset*1000).toLocaleString(Qt.locale(I18n.language === "de" ? "de_DE" : "en_US"),"ddd HH:mm") : tr("Keine Kontodaten","No account data"); }
    onOpenedChanged: { if (opened) { now = new Date(); refresh(); } }
    onTabChanged: { if (scroll.contentItem) scroll.contentItem.contentY = 0; if (opened) refresh(); }
    // One persistent surface: resizing never remaps the layer or triggers a compositor fade.
    readonly property real expandedWidth: Math.min(500, screen ? screen.width-24 : 500)
    readonly property real expandedHeight: Math.min(tab === "weather" ? 430 : 470, screen ? screen.height-65 : 470)
    property real animatedWidth: opened ? expandedWidth : 86
    property real animatedHeight: opened ? expandedHeight : 36
    Behavior on animatedWidth { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
    Behavior on animatedHeight { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
    visible: true
    anchors { top: true }
    margins.top: 10
    implicitWidth: Math.round(animatedWidth)
    implicitHeight: Math.round(animatedHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nyrix-dynamic-island"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    Timer { interval: 2500; repeat: true; running: island.opened && island.tab === "performance"; onTriggered: { if (!metrics.running) metrics.running = true; } }
    Timer { interval: 1000; repeat: true; running: true; onTriggered: { island.now = new Date(); if (island.opened && island.now.getSeconds() === 0 && (island.tab === "ai" || island.tab === "weather")) island.refresh(); } }
    Process { id: metrics; command: ["nyrix-island-data","metrics"]; stdout: StdioCollector { onStreamFinished: { try { const data=JSON.parse(text); if(data.error) island.error=data.error; else island.stats=data; } catch(e) { island.error=String(e); } } } }
    Process { id: aiProbe; command: ["nyrix-island-data","ai"]; stdout: StdioCollector { onStreamFinished: { try { const data=JSON.parse(text); if(data.error) island.error=data.error; else island.limits=data; } catch(e) { island.error=String(e); } } } }
    Process { id: weatherProbe; stdout: StdioCollector { onStreamFinished: { try { const data=JSON.parse(text); if(data.error) island.error=data.error; else if (data.locations !== undefined) { island.locations=data.locations; if (!data.locations.length) island.error=island.tr("Kein Ort gefunden","No locations found"); } else { island.weather=data; island.locations=[]; } } catch(e) { island.error=String(e); } } } }
    Rectangle {
        id: surface
        anchors.fill: parent; color: "#29292c"; radius: island.opened ? 22 : 18
        clip: true
        Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
        FocusScope {
            anchors.fill: parent; focus: true
            Keys.onEscapePressed: island.opened = false
            Item {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 36
                Text { anchors.centerIn: parent; text: island.now.toLocaleTimeString(Qt.locale(),"HH:mm"); color: "#ededf0"; font.pixelSize: 12; font.weight: Font.DemiBold }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: island.opened = !island.opened }
                SettingsButton {
                    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    visible: island.opened; opacity: islandBody.opacity
                    text: "↻"; implicitWidth: 28; implicitHeight: 26; leftPadding: 0; rightPadding: 0
                    onClicked: island.refresh(); Accessible.name: island.tr("Aktualisieren","Refresh")
                }
            }
            ColumnLayout {
                id: islandBody
                anchors { top: parent.top; topMargin: 44; horizontalCenter: parent.horizontalCenter }
                width: island.expandedWidth-32
                height: island.expandedHeight-60
                spacing: 12
                opacity: island.opened ? 1 : 0
                visible: opacity > 0
                enabled: island.opened
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: segments.implicitWidth; implicitHeight: 28
                    radius: 14; color: "#343439"
                    Row {
                        id: segments
                        spacing: 0
                        Repeater {
                            model: ["dashboard","performance","ai","weather"]
                            delegate: Button {
                                id: categoryButton
                                required property string modelData
                                required property int index
                                readonly property bool selected: island.tab === modelData
                                readonly property color fill: selected ? "#3d5147" : hovered ? "#414147" : "transparent"
                                implicitHeight: 28; implicitWidth: label.implicitWidth + 26
                                hoverEnabled: true
                                onClicked: island.tab = modelData
                                background: Item {
                                    Rectangle { anchors.fill: parent; radius: categoryButton.index === 0 || categoryButton.index === 3 ? 14 : 0; color: categoryButton.fill }
                                    Rectangle {
                                        visible: categoryButton.index === 0 || categoryButton.index === 3
                                        width: 14; height: parent.height
                                        x: categoryButton.index === 0 ? parent.width-width : 0
                                        color: categoryButton.fill
                                    }
                                    Rectangle { visible: categoryButton.index > 0; width: 1; height: 12; anchors.verticalCenter: parent.verticalCenter; color: "#66666f" }
                                }
                                contentItem: Text {
                                    id: label
                                    text: ({dashboard:"Dashboard",performance:"Performance",ai:"AI",weather:island.tr("Wetter","Weather")})[modelData]
                                    font.pixelSize: 11; font.weight: Font.DemiBold
                                    color: categoryButton.selected ? "#b9eed8" : "#bcbcc6"
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
                ScrollView {
                    id: scroll
                    Layout.fillWidth: true; Layout.fillHeight: true
                    contentWidth: availableWidth; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: scroll.availableWidth; spacing: 12
                        ColumnLayout {
                            visible: island.tab === "dashboard"; Layout.fillWidth: true; spacing: 16
                            IslandCalendar { Layout.fillWidth: true }
                            IslandMeter { label: island.tr("Laufzeit","Uptime"); value: island.stats.uptime !== undefined ? Math.floor(island.stats.uptime/3600)+" h "+Math.floor(island.stats.uptime%3600/60)+" min" : "—"; detail: "NyrixOS · Arch + Hyprland" }
                        }
                        ColumnLayout {
                            visible: island.tab === "performance"; Layout.fillWidth: true; spacing: 10
                            IslandMeter { label: "CPU"; value: island.pct(island.stats.cpu); percent: island.stats.cpu ?? -1; detail: island.tr("Temperatur: ","Temperature: ")+island.temp(island.stats.cpuTemp) }
                            Repeater { model: island.stats.gpus || []; delegate: IslandMeter { required property var modelData; label: "GPU · "+modelData.name; value: island.pct(modelData.usage); percent: modelData.usage ?? -1; detail: island.tr("Temperatur: ","Temperature: ")+island.temp(modelData.temperature) } }
                            IslandMeter { visible: !(island.stats.gpus || []).length; label: "GPU"; value: "—"; detail: island.tr("Keine auslesbaren GPU-Sensoren","No readable GPU sensors") }
                            IslandMeter { label: "RAM"; value: island.gib(island.stats.memoryUsed); percent: island.stats.memoryTotal ? 100*island.stats.memoryUsed/island.stats.memoryTotal : -1; detail: island.tr("Gesamt: ","Total: ")+island.gib(island.stats.memoryTotal) }
                            IslandMeter { label: island.tr("Systemplatte /","System disk /"); value: island.gib(island.stats.diskFree)+island.tr(" frei"," free"); percent: island.stats.diskTotal ? 100*island.stats.diskUsed/island.stats.diskTotal : -1; detail: island.tr("Belegt / Gesamt: ","Used / total: ")+island.gib(island.stats.diskUsed)+" / "+island.gib(island.stats.diskTotal) }
                            Text { text: island.tr("— bedeutet: kein Messwert verfügbar. Werte gelten für dieses System, nicht für den VM-Host.","— means no reading available. Metrics describe this system, not the VM host."); color: "#888893"; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        }
                        ColumnLayout {
                            visible: island.tab === "ai"; Layout.fillWidth: true; spacing: 12
                            Repeater {
                                model: ["claude","codex"]
                                delegate: SettingsCard {
                                    required property string modelData
                                    readonly property var account: island.limits[modelData] || ({})
                                    Layout.fillWidth: true
                                    heading: modelData === "claude" ? "Claude" : "ChatGPT / Codex"
                                    IslandMeter { label: island.tr("5-Stunden-Limit · verbraucht","5-hour limit · used"); value: island.pct(account.five_hour?.used); percent: account.five_hour?.used ?? -1; detail: island.resetText(account.five_hour) }
                                    IslandMeter { label: island.tr("Wochenlimit · verbraucht","Weekly limit · used"); value: island.pct(account.seven_day?.used); percent: account.seven_day?.used ?? -1; detail: island.resetText(account.seven_day) }
                                    Text { text: !account.connected ? island.tr("Nicht verbunden","Not connected") : (account.stale ? island.tr("Veralteter Stand · ","Stale reading · ") : island.tr("Stand: ","Updated: "))+new Date(account.sampledAt*1000).toLocaleString(); color: "#9999a4"; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                }
                            }
                            Text { text: island.tr("Claude: Statusline-Anbindung nötig. ChatGPT: Codex-Anmeldung nötig; diese Limits gelten für Codex, nicht pauschal für alle ChatGPT-Modelle.","Claude requires a status-line connection. ChatGPT requires Codex login; these are Codex limits, not universal ChatGPT model quotas."); color: "#9999a4"; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        }
                        ColumnLayout {
                            visible: island.tab === "weather"; Layout.fillWidth: true; spacing: 12
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: city; Layout.fillWidth: true; implicitHeight: 38; color: "#ededf0"; placeholderTextColor: "#92929f"; placeholderText: island.tr("Ort suchen …","Search city …"); leftPadding: 12; background: Rectangle { color: "#303034"; radius: 10 } onAccepted: search.clicked() }
                                SettingsButton { id: search; text: island.tr("Suchen","Search"); enabled: !weatherProbe.running && city.text.trim().length>1; onClicked: { island.error=""; weatherProbe.command=["nyrix-island-data","search",city.text.trim()]; weatherProbe.running=true; } }
                            }
                            Repeater { model: island.locations; delegate: SettingsButton { required property var modelData; Layout.fillWidth: true; text: modelData.name; enabled: !weatherProbe.running; onClicked: { weatherProbe.command=["nyrix-island-data","location",String(modelData.latitude),String(modelData.longitude),modelData.name]; weatherProbe.running=true; } } }
                            Text { visible: weatherProbe.running; text: I18n.tr("Laden …"); color: "#9999a4" }
                            Text { visible: !!island.weather.locationRequired; text: island.tr("Wähle deinen Ort. Keine automatische Standortfreigabe.","Choose your city. No automatic location sharing."); color: "#9999a4"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            ColumnLayout {
                                visible: !!island.weather.current; Layout.fillWidth: true; spacing: 12
                                Text { text: island.weather.location?.name || ""; textFormat: Text.PlainText; color: "#ededf0"; font.pixelSize: 16; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                IslandMeter { label: island.weather.current ? island.condition(island.weather.current.weather_code) : ""; value: island.temp(island.weather.current?.temperature_2m); detail: island.tr("Gefühlt ","Feels like ")+island.temp(island.weather.current?.apparent_temperature)+" · Wind "+(island.weather.current?.wind_speed_10m ?? "—")+" km/h" }
                                Repeater {
                                    model: island.weather.daily?.time || []
                                    delegate: RowLayout {
                                        required property int index
                                        required property string modelData
                                        Layout.fillWidth: true
                                        Text { text: new Date(modelData+"T12:00:00").toLocaleDateString(Qt.locale(I18n.language === "de" ? "de_DE" : "en_US"),"ddd, dd.MM"); color: "#bdbdc8"; Layout.preferredWidth: 105; font.pixelSize: 12 }
                                        Text { text: island.condition(island.weather.daily.weather_code[index]); color: "#92929f"; Layout.fillWidth: true; font.pixelSize: 12 }
                                        Text { text: Math.round(island.weather.daily.temperature_2m_min[index])+"° / "+Math.round(island.weather.daily.temperature_2m_max[index])+"°"; color: "#ededf0"; font.pixelSize: 12 }
                                    }
                                }
                                Text { text: (island.weather.stale ? island.tr("Offline · alter Stand: ","Offline · cached: ") : island.tr("Stand: ","Updated: "))+(island.weather.current?.time || "").replace("T"," "); color: "#92929f"; font.pixelSize: 11 }
                            }
                            Text { text: "Open-Meteo · CC BY 4.0"; color: "#888893"; font.pixelSize: 11; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://open-meteo.com/") } }
                        }
                        Text { visible: island.error !== ""; text: island.error; textFormat: Text.PlainText; color: "#efa6a6"; wrapMode: Text.WrapAnywhere; Layout.fillWidth: true }
                    }
                }
            }
        }
    }
}
