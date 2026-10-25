import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Hidden entirely when there is no adapter. Click opens bluetuith.
Row {
  id: root

  spacing: 6
  height: 16
  visible: root.adapter !== null

  // not `enabled`: Item already has one
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool adapterOn: root.adapter ? root.adapter.enabled : false
  readonly property var connectedDevices: Bluetooth.devices ? Bluetooth.devices.values.filter(d => d.connected) : []

  readonly property color tint: !root.adapterOn ? Colors.muted : root.connectedDevices.length > 0 ? Colors.sky : Colors.text
  readonly property string label: !root.adapterOn ? "Bluetooth off" : root.connectedDevices.length > 0 ? root.connectedDevices.map(d => d.deviceName || d.name).join(", ") : "Bluetooth"

  // the window this opens
  readonly property var managerCommand: ["footclient", "--app-id=bluetuith", "bluetuith"]

  Item {
    id: btIcon
    width: 16
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    Canvas {
      id: btCanvas
      anchors.fill: parent
      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.strokeStyle = root.tint;
        ctx.lineWidth = 1.5;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        // a vertical stroke with a chevron above and below
        ctx.beginPath();
        ctx.moveTo(5, 11);
        ctx.lineTo(11, 5);
        ctx.lineTo(8, 2);
        ctx.lineTo(8, 14);
        ctx.lineTo(11, 11);
        ctx.lineTo(5, 5);
        ctx.stroke();

        // struck through when off, rather than just dimmer
        if (!root.adapterOn) {
          ctx.strokeStyle = Colors.muted;
          ctx.beginPath();
          ctx.moveTo(2, 14);
          ctx.lineTo(14, 2);
          ctx.stroke();
        }
      }

      Connections {
        target: root
        function onTintChanged() {
          btCanvas.requestPaint();
        }
        function onAdapterOnChanged() {
          btCanvas.requestPaint();
        }
      }
    }
  }

  Tooltip {
    anchorItem: btIcon
    text: root.label
    hovered: btHover.hovered
  }

  HoverHandler {
    id: btHover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: Quickshell.execDetached(root.managerCommand)
  }
}
