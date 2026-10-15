import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
  required property var modelData
  screen: modelData

  // under every window, and no exclusive zone, so windows keep the full screen
  WlrLayershell.layer: WlrLayer.Background
  exclusionMode: ExclusionMode.Ignore

  // its own namespace, so the niri layer-rule can tell this surface from the
  // bar and the notifications
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

    // The image is 7680x4320, 16:9 like both screens here, so nothing is
    // actually cropped. Kept for the day it meets a screen that is not.
    fillMode: Image.PreserveAspectCrop

    asynchronous: true
    cache: true
  }
}
