import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
  required property var modelData
  screen: modelData

  // Sits under every window, and is not an exclusive zone, so windows still
  // use the whole screen.
  WlrLayershell.layer: WlrLayer.Background
  exclusionMode: ExclusionMode.Ignore

  // A namespace of its own so the niri layer-rule can pick this surface out
  // from the bar and the notifications, which are quickshell surfaces too.
  WlrLayershell.namespace: "quickshell-wallpaper"

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: Colors.base

  Image {
    anchors.fill: parent
    source: "wallpaper.jpg"

    // The image is 7680x4320, exactly 16:9, which is also the shape of both
    // screens here -- so this scales down to an exact fit and crops nothing.
    // PreserveAspectCrop is kept for the day it meets a screen that is not
    // 16:9, where filling and cropping beats letterboxing.
    fillMode: Image.PreserveAspectCrop

    asynchronous: true
    cache: true
  }
}
