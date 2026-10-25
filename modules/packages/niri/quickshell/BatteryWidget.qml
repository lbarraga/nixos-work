import QtQuick
import Quickshell.Services.UPower

// The icon is drawn, not a font glyph, so nothing depends on which runes the
// monospace font ships.
Row {
  id: root

  spacing: 6
  height: 14
  visible: bat !== null && bat.isPresent

  readonly property var bat: UPower.displayDevice

  // a 0..1 ratio, not a percentage
  readonly property int pct: bat ? Math.round(bat.percentage * 100) : 0

  // 1 charging, 2 discharging, 4 full, 5 pending. Not `UPower.onBattery`:
  // this laptop exposes three line-power devices and the aggregate reads
  // false while the battery is draining.
  readonly property bool charging: bat ? bat.state === 1 || bat.state === 5 : false
  readonly property bool full: bat ? bat.state === 4 : false

  readonly property color levelColor: charging || full ? Colors.fern : pct <= 15 ? Colors.ember : pct <= 30 ? Colors.wheat : Colors.text

  Item {
    width: 24
    height: 12
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
      id: shell
      width: 21
      height: 12
      radius: 3
      color: "transparent"
      border.width: 1
      border.color: Colors.muted
    }

    Rectangle {
      x: 2
      anchors.verticalCenter: shell.verticalCenter
      width: Math.max(1, (shell.width - 4) * Math.min(100, Math.max(0, root.pct)) / 100)
      height: shell.height - 4
      radius: 1
      color: root.levelColor

      Behavior on width {
        NumberAnimation {
          duration: 300
        }
      }
      Behavior on color {
        ColorAnimation {
          duration: 300
        }
      }
    }

    // the positive terminal
    Rectangle {
      x: shell.width
      anchors.verticalCenter: shell.verticalCenter
      width: 2
      height: 5
      radius: 1
      color: Colors.muted
    }

    // a bolt over the fill while charging
    Canvas {
      id: bolt
      anchors.fill: shell
      visible: root.charging
      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = Colors.base;
        ctx.beginPath();
        ctx.moveTo(width * 0.56, 1);
        ctx.lineTo(width * 0.36, height * 0.58);
        ctx.lineTo(width * 0.50, height * 0.58);
        ctx.lineTo(width * 0.44, height - 1);
        ctx.lineTo(width * 0.66, height * 0.42);
        ctx.lineTo(width * 0.52, height * 0.42);
        ctx.closePath();
        ctx.fill();
      }
      onVisibleChanged: bolt.requestPaint()
    }
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.pct + "%"
    color: root.levelColor
    font.family: "monospace"
    font.pixelSize: 12
  }
}
