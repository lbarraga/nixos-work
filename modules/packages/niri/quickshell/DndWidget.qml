import QtQuick
import Quickshell

// Click toggles do not disturb. Sand rather than muted when it is on: this is
// a state you want to be reminded of, like "no internet".
Row {
  id: root

  spacing: 6
  height: 16

  readonly property color tint: Dnd.active ? Colors.wheat : Colors.text
  readonly property string label: Dnd.active
    ? "Do not disturb -- only urgent"
    : "Notifications on"

  Item {
    id: dndIcon
    width: 16
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    Canvas {
      id: dndCanvas
      anchors.fill: parent
      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.strokeStyle = root.tint;
        ctx.lineWidth = 1.5;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        // the bell: two sides closed by a dome on top and a line beneath
        ctx.beginPath();
        ctx.moveTo(4, 11);
        ctx.lineTo(4, 7.5);
        ctx.arc(8, 7.5, 4, Math.PI, 0);
        ctx.lineTo(12, 11);
        ctx.closePath();
        ctx.stroke();

        // the clapper
        ctx.beginPath();
        ctx.arc(8, 11.5, 1.5, 0, Math.PI);
        ctx.stroke();

        // struck through when silenced, the same way bluetooth-off reads
        if (Dnd.active) {
          ctx.beginPath();
          ctx.moveTo(2, 14);
          ctx.lineTo(14, 2);
          ctx.stroke();
        }
      }

      Connections {
        target: Dnd
        function onActiveChanged() {
          dndCanvas.requestPaint();
        }
      }
    }
  }

  Tooltip {
    anchorItem: dndIcon
    text: root.label
    hovered: dndHover.hovered
  }

  HoverHandler {
    id: dndHover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: Dnd.toggle()
  }
}
