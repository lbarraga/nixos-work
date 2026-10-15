import Quickshell
import QtQuick

// A hover popup in its own window. The bar is 30px tall and sets an exclusive
// zone, so anything drawn inside it would be clipped at the edge -- a tooltip
// has to be a separate surface.
PopupWindow {
  id: root

  // The widget the popup hangs under.
  required property Item anchorItem
  required property string text

  // Driven by the widget's HoverHandler.
  property bool hovered: false

  // Nothing appears until the pointer has settled, so crossing the status
  // icons on the way somewhere else does not flash three popups.
  property bool shown: false

  anchor.item: root.anchorItem
  anchor.edges: Edges.Bottom
  anchor.gravity: Edges.Bottom
  anchor.margins.top: 8

  implicitWidth: label.implicitWidth + 18
  implicitHeight: label.implicitHeight + 12

  visible: root.shown && root.text !== ""
  color: "transparent"

  onHoveredChanged: {
    if (root.hovered) {
      delay.restart();
    } else {
      delay.stop();
      root.shown = false;
    }
  }

  Timer {
    id: delay
    interval: 350
    onTriggered: root.shown = true
  }

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: Colors.cardBackground
    border.width: 1
    border.color: Colors.overlay

    Text {
      id: label
      anchors.centerIn: parent
      text: root.text
      color: Colors.text
      font.family: "monospace"
      font.pixelSize: 12
    }
  }
}
