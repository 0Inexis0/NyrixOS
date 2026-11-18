import QtQuick
import QtQuick.Controls
Slider {
    id: slider
    from: 0; to: 1
    implicitHeight: 28
    opacity: enabled ? 1 : 0.3
    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth; height: 6; radius: 3
        color: "#484848"
        Rectangle { width: slider.visualPosition * parent.width; height: parent.height; radius: 3; color: "#a7ede1" }
    }
    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 18; height: 18; radius: 9
        color: slider.pressed ? "#ffffff" : "#a7ede1"
    }
}
