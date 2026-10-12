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

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "#1e1e2e"

  Image {
    anchors.fill: parent
    source: "wallpaper.jpg"

    // The painting is taller than either screen, so filling the width leaves
    // vertical overflow. AlignBottom throws away sky rather than sea.
    fillMode: Image.PreserveAspectCrop
    verticalAlignment: Image.AlignBottom

    asynchronous: true
    cache: true
  }
}
