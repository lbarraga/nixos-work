import QtQuick
import Quickshell
import Quickshell.Wayland

// Click opens a panel of system readouts. Everything it draws comes from the
// SysInfo singleton, so the several bars on a multi-monitor setup share one
// set of counters.
Row {
  id: root

  spacing: 6
  height: 16

  // the bar is one window per screen; the panel needs the same one
  required property var screenInfo

  property bool open: false

  readonly property string label: "CPU " + Math.round(SysInfo.cpu * 100) + "%  ·  RAM " + SysInfo.formatSize(SysInfo.memUsed)

  onOpenChanged: {
    if (root.open)
      SysInfo.watch();
    else
      SysInfo.unwatch();
  }

  // The four glyphs the panel and the bar share. One canvas rather than four
  // files: none of them is useful on its own.
  component Glyph: Canvas {
    id: glyph

    property string kind: "cpu"
    property color tint: Colors.text

    width: 16
    height: 16

    onTintChanged: glyph.requestPaint()

    onPaint: {
      const ctx = getContext("2d");
      ctx.reset();
      ctx.strokeStyle = glyph.tint;
      ctx.fillStyle = glyph.tint;
      ctx.lineWidth = 1.3;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";

      if (glyph.kind === "cpu") {
        // a chip: the die, its core, and three pins a side
        ctx.strokeRect(4.5, 4.5, 7, 7);
        ctx.strokeRect(6.5, 6.5, 3, 3);
        for (let i = 0; i < 3; i++) {
          const at = 5.5 + i * 2.5;
          ctx.beginPath();
          ctx.moveTo(at, 4.5);
          ctx.lineTo(at, 2);
          ctx.moveTo(at, 11.5);
          ctx.lineTo(at, 14);
          ctx.moveTo(4.5, at);
          ctx.lineTo(2, at);
          ctx.moveTo(11.5, at);
          ctx.lineTo(14, at);
          ctx.stroke();
        }
      } else if (glyph.kind === "ram") {
        // a module: the board and its row of chips. No contact pins below --
        // at this size they read as legs, and the chip count already says it
        ctx.strokeRect(1.5, 4, 13, 8);
        for (let i = 0; i < 3; i++)
          ctx.fillRect(3.5 + i * 3.25, 6.5, 2.5, 3);
      } else if (glyph.kind === "disk") {
        // a platter stack, seen from the side
        ctx.beginPath();
        ctx.ellipse(2.5, 2.5, 11, 4);
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(2.5, 4.5);
        ctx.lineTo(2.5, 11.5);
        ctx.moveTo(13.5, 4.5);
        ctx.lineTo(13.5, 11.5);
        ctx.stroke();
        ctx.beginPath();
        ctx.ellipse(2.5, 9.5, 11, 4);
        ctx.stroke();
      } else {
        // an arrow, down for "up" false
        const dir = glyph.kind === "up" ? -1 : 1;
        const mid = 8;
        ctx.beginPath();
        ctx.moveTo(mid, mid - 5 * dir);
        ctx.lineTo(mid, mid + 5 * dir);
        ctx.moveTo(mid - 3.5, mid + 1.5 * dir);
        ctx.lineTo(mid, mid + 5 * dir);
        ctx.lineTo(mid + 3.5, mid + 1.5 * dir);
        ctx.stroke();
      }
    }
  }

  // A line over the last SysInfo.historyLength samples, anchored right so it
  // grows in from the edge rather than stretching two points across the width.
  component Sparkline: Canvas {
    id: spark

    // 0..1, oldest first
    property var values: []
    property color tint: Colors.sky

    onValuesChanged: spark.requestPaint()

    onPaint: {
      const ctx = getContext("2d");
      ctx.reset();

      const n = spark.values.length;
      if (n < 2)
        return;

      // half a line width of inset, so a full or empty graph is not clipped
      const top = 1;
      const bottom = height - 1;
      const step = width / (SysInfo.historyLength - 1);
      const xAt = i => width - (n - 1 - i) * step;
      const yAt = v => bottom - Math.max(0, Math.min(1, v)) * (bottom - top);

      // the area under the line, faint, so a flat graph still reads as a surface
      ctx.beginPath();
      ctx.moveTo(xAt(0), yAt(spark.values[0]));
      for (let i = 1; i < n; i++)
        ctx.lineTo(xAt(i), yAt(spark.values[i]));
      ctx.lineTo(xAt(n - 1), height);
      ctx.lineTo(xAt(0), height);
      ctx.closePath();
      ctx.fillStyle = Qt.rgba(spark.tint.r, spark.tint.g, spark.tint.b, 0.12);
      ctx.fill();

      ctx.beginPath();
      ctx.moveTo(xAt(0), yAt(spark.values[0]));
      for (let i = 1; i < n; i++)
        ctx.lineTo(xAt(i), yAt(spark.values[i]));
      ctx.strokeStyle = spark.tint;
      ctx.lineWidth = 1.5;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";
      ctx.stroke();
    }
  }

  // One leg of the chip package. Top level rather than nested in CoreGrid:
  // an inline component cannot declare another one inside itself.
  component Pin: Rectangle {
    radius: 1
    color: Colors.overlay
  }

  // One square per core, filled from the bottom by its load, laid out inside a
  // chip package with pins -- the same shape as the bar glyph. The grid is
  // sized from the core count rather than hardcoded, so it is as square as the
  // number allows on any machine; see SysInfo.gridColumns.
  component CoreGrid: Item {
    id: grid

    // 0..1, one per core
    property var loads: []

    property int gap: 4
    property int maxCell: 48

    // the package border's inset, and the pins outside it
    property int pad: 10
    property int pinLength: 6
    property int pinWidth: 2

    readonly property int columns: SysInfo.gridColumns(grid.loads.length)
    readonly property int rows: Math.ceil(grid.loads.length / grid.columns)

    // fill the width the panel gives us, up to a size where one core on a dual
    // core machine would stop looking like a core and start looking like a tile
    readonly property int cell: {
      const room = grid.width - 2 * (grid.pinLength + grid.pad) - (grid.columns - 1) * grid.gap;
      return Math.max(5, Math.min(grid.maxCell, Math.floor(room / grid.columns)));
    }

    readonly property int gridWidth: grid.columns * grid.cell + (grid.columns - 1) * grid.gap
    readonly property int gridHeight: grid.rows * grid.cell + (grid.rows - 1) * grid.gap

    implicitHeight: grid.loads.length > 0 ? grid.gridHeight + 2 * (grid.pad + grid.pinLength) : 0
    visible: grid.loads.length > 0

    Rectangle {
      id: pkg

      anchors.centerIn: parent
      width: grid.gridWidth + 2 * grid.pad
      height: grid.gridHeight + 2 * grid.pad
      radius: 6

      color: Qt.rgba(Colors.base.r, Colors.base.g, Colors.base.b, 0.5)
      border.width: 1
      border.color: Colors.overlay

      Grid {
        anchors.centerIn: parent
        columns: grid.columns
        spacing: grid.gap

        Repeater {
          model: grid.loads.length

          Rectangle {
            id: tile
            required property int index

            width: grid.cell
            height: grid.cell
            radius: 2
            color: Colors.overlay

            Rectangle {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              radius: 2
              color: Colors.sky
              height: Math.round(parent.height * Math.max(0, Math.min(1, grid.loads[tile.index])))

              Behavior on height {
                NumberAnimation {
                  duration: 250
                  easing.type: Easing.OutQuad
                }
              }
            }
          }
        }
      }
    }

    // One pin per column on the top and bottom edges, one per row on the
    // sides, so the package keeps its proportions whatever the core count is.
    Repeater {
      model: grid.columns
      Pin {
        required property int index
        width: grid.pinWidth
        height: grid.pinLength
        x: pkg.x + grid.pad + index * (grid.cell + grid.gap) + (grid.cell - grid.pinWidth) / 2
        y: pkg.y - grid.pinLength
      }
    }

    Repeater {
      model: grid.columns
      Pin {
        required property int index
        width: grid.pinWidth
        height: grid.pinLength
        x: pkg.x + grid.pad + index * (grid.cell + grid.gap) + (grid.cell - grid.pinWidth) / 2
        y: pkg.y + pkg.height
      }
    }

    Repeater {
      model: grid.rows
      Pin {
        required property int index
        width: grid.pinLength
        height: grid.pinWidth
        x: pkg.x - grid.pinLength
        y: pkg.y + grid.pad + index * (grid.cell + grid.gap) + (grid.cell - grid.pinWidth) / 2
      }
    }

    Repeater {
      model: grid.rows
      Pin {
        required property int index
        width: grid.pinLength
        height: grid.pinWidth
        x: pkg.x + pkg.width
        y: pkg.y + grid.pad + index * (grid.cell + grid.gap) + (grid.cell - grid.pinWidth) / 2
      }
    }
  }

  // One of the rounded panels the readouts sit in.
  component Card: Rectangle {
    default property alias body: cardBody.data

    radius: 8
    color: Colors.panelCard
    implicitHeight: cardBody.implicitHeight + 20

    Column {
      id: cardBody
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 10
      spacing: 8
    }
  }

  // A glyph in a tile, a number, and the graph behind it.
  component StatRow: Item {
    property string kind: "cpu"
    property string value: ""
    property int valueWidth: 92
    property var history: []
    property color tint: Colors.sky

    implicitHeight: 28

    Rectangle {
      id: tile
      width: 26
      height: 26
      radius: 6
      color: Colors.overlay
      anchors.verticalCenter: parent.verticalCenter

      Glyph {
        anchors.centerIn: parent
        kind: parent.parent.kind
        tint: Colors.text
      }
    }

    Text {
      id: reading
      anchors.left: tile.right
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      width: parent.valueWidth
      text: parent.value
      color: Colors.text
      font.family: "monospace"
      font.pixelSize: 13
    }

    Sparkline {
      anchors.left: reading.right
      anchors.leftMargin: 12
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 24
      values: parent.history
      tint: parent.tint
    }
  }

  Item {
    id: chipIcon
    width: 16
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    Glyph {
      anchors.fill: parent
      kind: "cpu"
      tint: root.open ? Colors.sky : Colors.text
    }
  }

  Tooltip {
    anchorItem: chipIcon
    text: root.label
    hovered: chipHover.hovered && !root.open
  }

  HoverHandler {
    id: chipHover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.open = !root.open
  }

  // A full-screen layer rather than a PopupWindow: a popup cannot tell when
  // the pointer goes somewhere else, and this surface catches that click. It
  // also places the card by screen margins instead of by whatever the bar
  // happens to clamp a popup to.
  PanelWindow {
    id: panel

    screen: root.screenInfo
    visible: root.open
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-sysinfo"
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // anything outside the card dismisses it
    MouseArea {
      anchors.fill: parent
      onClicked: root.open = false
    }

    Rectangle {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: 44
      anchors.rightMargin: 14

      width: 300
      height: body.implicitHeight + 20

      radius: 10
      color: Colors.cardBackground
      border.width: 1
      border.color: Colors.overlay

      // the card is not the backdrop, so clicks on it must not close it
      MouseArea {
        anchors.fill: parent
      }

      Column {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        // memory, then the processor with its cores directly beneath it
        Card {
          width: parent.width

          StatRow {
            width: parent.width
            kind: "ram"
            value: SysInfo.formatSize(SysInfo.memUsed) + " / " + SysInfo.formatSize(SysInfo.memTotal)
            history: SysInfo.memHistory
            tint: Colors.iris
          }

          StatRow {
            width: parent.width
            kind: "cpu"
            value: Math.round(SysInfo.cpu * 100) + "%"
            history: SysInfo.cpuHistory
            tint: Colors.sky
          }

          CoreGrid {
            width: parent.width
            loads: SysInfo.cores
          }
        }

        // network
        Card {
          width: parent.width

          Item {
            width: parent.width
            implicitHeight: 34

            Column {
              anchors.left: parent.left
              spacing: 2

              Row {
                spacing: 6
                Glyph {
                  kind: "down"
                  tint: Colors.mint
                  anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                  text: SysInfo.formatRate(SysInfo.rxRate)
                  color: Colors.text
                  font.family: "monospace"
                  font.pixelSize: 13
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              Text {
                text: "Download"
                color: Colors.muted
                font.family: "monospace"
                font.pixelSize: 10
              }
            }

            Rectangle {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
              width: 1
              height: 26
              color: Colors.muted
              opacity: 0.3
            }

            Column {
              anchors.right: parent.right
              spacing: 2

              Row {
                anchors.right: parent.right
                spacing: 6
                Text {
                  text: SysInfo.formatRate(SysInfo.txRate)
                  color: Colors.text
                  font.family: "monospace"
                  font.pixelSize: 13
                  anchors.verticalCenter: parent.verticalCenter
                }
                Glyph {
                  kind: "up"
                  tint: Colors.haze
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              Text {
                anchors.right: parent.right
                text: "Upload"
                color: Colors.muted
                font.family: "monospace"
                font.pixelSize: 10
              }
            }
          }
        }

        // disk
        Card {
          width: parent.width

          Row {
            spacing: 10

            Glyph {
              kind: "disk"
              tint: Colors.text
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "/   " + SysInfo.formatSize(SysInfo.diskUsed) + " / " + SysInfo.formatSize(SysInfo.diskTotal)
              color: Colors.text
              font.family: "monospace"
              font.pixelSize: 13
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Item {
            width: parent.width
            implicitHeight: 10

            Rectangle {
              id: diskTrack
              anchors.left: parent.left
              anchors.right: diskPercent.left
              anchors.rightMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              height: 6
              radius: 3
              color: Colors.overlay

              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 3
                color: Colors.sky
                width: SysInfo.diskTotal > 0 ? Math.round(parent.width * SysInfo.diskUsed / SysInfo.diskTotal) : 0
              }
            }

            Text {
              id: diskPercent
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: SysInfo.diskTotal > 0 ? Math.round(SysInfo.diskUsed / SysInfo.diskTotal * 100) + "%" : "--"
              color: Colors.muted
              font.family: "monospace"
              font.pixelSize: 11
            }
          }
        }
      }
    }
  }
}
