import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Hidden entirely on a machine with no adapter, so the bar does not carry a
// dead icon around. Click opens blueman, which is where pairing happens.
Row {
  id: root

  spacing: 6
  height: 16
  visible: root.adapter !== null

  // `adapterOn` rather than `enabled`: Item already has an `enabled` property.
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool adapterOn: root.adapter ? root.adapter.enabled : false
  readonly property var connectedDevices: Bluetooth.devices ? Bluetooth.devices.values.filter(d => d.connected) : []

  readonly property color tint: !root.adapterOn ? Colors.muted : root.connectedDevices.length > 0 ? Colors.sky : Colors.text
  readonly property string label: !root.adapterOn ? "Bluetooth off" : root.connectedDevices.length > 0 ? root.connectedDevices.map(d => d.deviceName || d.name).join(", ") : "Bluetooth"

  // The GTK window this opens. One line to change if blueman is ever swapped
  // for something else.
  readonly property var managerCommand: ["blueman-manager"]

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

        // The rune: a vertical stroke with a chevron above and below.
        ctx.beginPath();
        ctx.moveTo(5, 11);
        ctx.lineTo(11, 5);
        ctx.lineTo(8, 2);
        ctx.lineTo(8, 14);
        ctx.lineTo(11, 11);
        ctx.lineTo(5, 5);
        ctx.stroke();

        // Struck through when the adapter is off, so "off" is not just a
        // slightly dimmer icon.
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
