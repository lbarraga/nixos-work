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

  color: "#0c1a21"

  Image {
    anchors.fill: parent
    source: "wallpaper.jpg"

    // The scan keeps the bare canvas edge all the way around, a cream line a
    // couple of dozen pixels wide that reads as a glitch once it is stretched
    // across a screen. These numbers are the painted area of this exact file,
    // which is safe to hardcode: the image is pinned by hash in niri.nix.
    sourceClipRect: Qt.rect(26, 20, 2352, 1860)

    // The painting is taller than either screen, so filling the width leaves
    // vertical overflow. AlignTop throws away water rather than the sun, which
    // sits in the top left corner.
    fillMode: Image.PreserveAspectCrop
    verticalAlignment: Image.AlignTop

    asynchronous: true
    cache: true
  }
}
