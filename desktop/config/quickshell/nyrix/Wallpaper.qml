import QtQuick
import Quickshell
import Quickshell.Wayland

// One background per output; original image is preserved, cropped only for display.
Variants {
    model: Quickshell.screens
    PanelWindow {
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "nyrix-wallpaper"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "#303344"
        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("wallpaper.png")
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }
}
