import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// Collapses into its own chevron, and starts collapsed.
Row {
  id: root

  // a tray menu is a popup anchored to this window
  required property var barWindow

  property bool expanded: true

  // A Passive item is asking to be hidden. udiskie sits there permanently:
  readonly property var items: SystemTray.items ? SystemTray.items.values.filter(i => i.status !== Status.Passive) : []

  spacing: 6
  height: 16
  visible: root.items.length > 0

  Item {
    id: toggle
    width: 16
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    Canvas {
      id: chevron
      anchors.fill: parent
      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.strokeStyle = toggleHover.hovered ? Colors.glow : Colors.muted;
        ctx.lineWidth = 1.6;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        // points the way it will move
        const x0 = root.expanded ? 6 : 10;
        const dx = root.expanded ? 4 : -4;
        ctx.beginPath();
        ctx.moveTo(x0 + dx, 4);
        ctx.lineTo(x0, 8);
        ctx.lineTo(x0 + dx, 12);
        ctx.stroke();
      }

      Connections {
        target: root
        function onExpandedChanged() {
          chevron.requestPaint();
        }
      }
      Connections {
        target: toggleHover
        function onHoveredChanged() {
          chevron.requestPaint();
        }
      }
    }

    // so a collapsed tray still says how much it hides
    Text {
      anchors.left: parent.right
      anchors.leftMargin: 1
      anchors.verticalCenter: parent.verticalCenter
      visible: !root.expanded
      text: root.items.length
      color: Colors.muted
      font.family: "monospace"
      font.pixelSize: 10
    }

    HoverHandler {
      id: toggleHover
      cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
      onTapped: root.expanded = !root.expanded
    }
  }

  Item {
    height: parent.height
    width: root.expanded ? icons.implicitWidth + icons.anchors.leftMargin : 0
    clip: true

    Behavior on width {
      NumberAnimation {
        duration: 180
        easing.type: Easing.OutCubic
      }
    }

    Row {
      id: icons
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 6
      spacing: 8

      Repeater {
        model: root.items

        delegate: Item {
          id: entry
          required property var modelData

          width: 16
          height: 16

          IconImage {
            anchors.fill: parent
            source: entry.modelData.icon
            opacity: entryHover.hovered ? 1 : 0.82

            Behavior on opacity {
              NumberAnimation {
                duration: 120
              }
            }
          }

          HoverHandler {
            id: entryHover
            cursorShape: Qt.PointingHandCursor
          }

          TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: eventPoint => {
              if (eventPoint.event.button === Qt.RightButton || entry.modelData.onlyMenu)
                entry.modelData.display(root.barWindow, entry.width / 2, entry.height);
              else
                entry.modelData.activate();
            }
          }
        }
      }
    }
  }
}
