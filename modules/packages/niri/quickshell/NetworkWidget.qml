import QtQuick
import Quickshell
import Quickshell.Networking

// Wired wins when both are up, which is what the traffic does anyway.
Row {
  id: root

  spacing: 6
  height: 16

  readonly property var devices: Networking.devices ? Networking.devices.values : []
  readonly property var wired: root.devices.find(d => d.type === DeviceType.Wired && d.connected) || null
  readonly property var wifi: root.devices.find(d => d.type === DeviceType.Wifi && d.connected) || null
  readonly property var wifiNetwork: root.wifi && root.wifi.networks && root.wifi.networks.values ? root.wifi.networks.values.find(n => n.connected) || null : null

  readonly property bool online: root.wired !== null || root.wifi !== null

  // Associated is not the same as reaching the internet -- a captive portal
  // leaves the link up with nothing behind it. Unknown counts as fine: that is
  // what it reads when the check is switched off.
  readonly property bool limited: root.online && Networking.connectivity !== NetworkConnectivity.Full && Networking.connectivity !== NetworkConnectivity.Unknown

  readonly property string connectionName: root.wired ? "Ethernet" : root.wifiNetwork ? root.wifiNetwork.name : root.wifi ? "Wi-Fi" : ""

  readonly property color tint: !root.online ? Colors.muted : root.limited ? Colors.sand : Colors.text
  readonly property string label: !root.online ? "Offline" : root.limited ? root.connectionName + " - no internet" : root.connectionName

  // Comes from features/network.nix, not from the niri package, so on another
  // machine this click is a no-op.
  readonly property var managerCommand: ["networkmanager_dmenu"]

  Item {
    id: icon
    width: 16
    height: 14
    anchors.verticalCenter: parent.verticalCenter

    Canvas {
      id: netCanvas
      anchors.fill: parent
      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.strokeStyle = root.tint;
        ctx.fillStyle = root.tint;
        ctx.lineWidth = 1.4;
        ctx.lineCap = "round";

        if (root.wired) {
          ctx.beginPath();
          ctx.rect(2.5, 5.5, 11, 7);
          ctx.stroke();
          ctx.beginPath();
          ctx.moveTo(8, 5.5);
          ctx.lineTo(8, 1.5);
          ctx.stroke();
          ctx.fillRect(5.5, 8.5, 5, 4);
        } else {
          const cx = 8;
          const cy = 12.5;
          const radii = [3, 6, 9];
          for (var i = 0; i < radii.length; i++) {
            // offline keeps only the innermost arc lit
            ctx.globalAlpha = root.online ? 1 : i === 0 ? 1 : 0.25;
            ctx.beginPath();
            ctx.arc(cx, cy, radii[i], Math.PI * 1.25, Math.PI * 1.75);
            ctx.stroke();
          }
          ctx.globalAlpha = 1;
          ctx.beginPath();
          ctx.arc(cx, cy, 1, 0, Math.PI * 2);
          ctx.fill();
        }

        // struck through when nothing is connected; dimming is too easy to miss
        if (!root.online) {
          ctx.strokeStyle = Colors.muted;
          ctx.beginPath();
          ctx.moveTo(2, 13);
          ctx.lineTo(14, 1);
          ctx.stroke();
        }
      }

      Connections {
        target: root
        function onTintChanged() {
          netCanvas.requestPaint();
        }
        function onOnlineChanged() {
          netCanvas.requestPaint();
        }
        function onWiredChanged() {
          netCanvas.requestPaint();
        }
        function onLimitedChanged() {
          netCanvas.requestPaint();
        }
      }
    }
  }

  Tooltip {
    anchorItem: icon
    text: root.label
    hovered: hover.hovered
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: Quickshell.execDetached(root.managerCommand)
  }
}
