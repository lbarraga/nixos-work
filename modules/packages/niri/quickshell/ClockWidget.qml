import QtQuick
import Quickshell
import Quickshell.Wayland

// The bar's clock. Click opens a month calendar: today is marked, the rest of
// the grid is there to answer "what day does the 14th fall on".
Item {
  id: root

  // the bar is one window per screen; the panel needs the same one
  required property var screenInfo

  property bool open: false

  // the month on screen, as an offset from the current one, so the grid keeps
  // following the clock across midnight instead of pinning to a stale month
  property int monthOffset: 0

  implicitWidth: label.implicitWidth
  implicitHeight: label.implicitHeight

  readonly property var today: clock.date
  readonly property var shown: new Date(root.today.getFullYear(), root.today.getMonth() + root.monthOffset, 1)

  // six rows always, so navigating a month never resizes the card
  readonly property var cells: {
    const lead = (root.shown.getDay() + 6) % 7;
    const out = [];
    for (let i = 0; i < 42; i++) {
      const d = new Date(root.shown.getFullYear(), root.shown.getMonth(), 1 - lead + i);
      out.push({
        day: d.getDate(),
        inMonth: d.getMonth() === root.shown.getMonth() && d.getFullYear() === root.shown.getFullYear(),
        isToday: d.getDate() === root.today.getDate() && d.getMonth() === root.today.getMonth() && d.getFullYear() === root.today.getFullYear(),
        weekend: i % 7 >= 5
      });
    }
    return out;
  }

  // always open on the month we are in
  onOpenChanged: if (root.open)
    root.monthOffset = 0

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: Qt.formatDateTime(root.today, "HH:mm")
    color: root.open || clockHover.hovered ? Colors.sky : Colors.text
    font.family: "monospace"
    font.pixelSize: 14
  }

  Tooltip {
    anchorItem: root
    text: Qt.formatDate(root.today, "dddd d MMMM yyyy")
    hovered: clockHover.hovered && !root.open
  }

  HoverHandler {
    id: clockHover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.open = !root.open
  }

  // A chevron that steps the month. Canvas rather than a glyph, like the rest
  // of the bar, so nothing depends on which runes the font ships.
  component NavButton: Item {
    id: nav

    property int step: 1

    width: 24
    height: 24

    Canvas {
      id: arrow
      anchors.fill: parent

      onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.strokeStyle = navHover.hovered ? Colors.sky : Colors.muted;
        ctx.lineWidth = 1.6;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        const x0 = nav.step < 0 ? 14 : 10;
        const dx = nav.step < 0 ? -4 : 4;
        ctx.beginPath();
        ctx.moveTo(x0, 6);
        ctx.lineTo(x0 + dx, 12);
        ctx.lineTo(x0, 18);
        ctx.stroke();
      }
    }

    HoverHandler {
      id: navHover
      cursorShape: Qt.PointingHandCursor
      onHoveredChanged: arrow.requestPaint()
    }

    TapHandler {
      onTapped: root.monthOffset += nav.step
    }
  }

  // A full-screen layer rather than a PopupWindow: a popup cannot tell when
  // the pointer goes somewhere else, and this surface catches that click.
  PanelWindow {
    id: panel

    screen: root.screenInfo
    visible: root.open
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-calendar"
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
      anchors.topMargin: 44
      anchors.horizontalCenter: parent.horizontalCenter

      width: body.implicitWidth + 28
      height: body.implicitHeight + 28

      radius: 10
      color: Colors.cardBackground
      border.width: 1
      border.color: Colors.overlay

      // the card is not the backdrop, so clicks on it must not close it
      MouseArea {
        anchors.fill: parent
      }

      // the grid is a month wide in either direction
      WheelHandler {
        onWheel: event => root.monthOffset += event.angleDelta.y > 0 ? -1 : 1
      }

      Column {
        id: body
        anchors.centerIn: parent
        spacing: 6

        // month, year, and the two steppers
        Item {
          width: grid.width
          height: 26

          NavButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            step: -1
          }

          Text {
            id: title
            anchors.centerIn: parent
            text: Qt.formatDate(root.shown, "MMMM yyyy")
            color: titleHover.hovered ? Colors.sky : Colors.text
            font.family: "monospace"
            font.pixelSize: 14

            // back to the month we are in
            HoverHandler {
              id: titleHover
              cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
              onTapped: root.monthOffset = 0
            }
          }

          NavButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            step: 1
          }
        }

        Row {
          Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            delegate: Text {
              required property int index
              required property string modelData

              width: 36
              horizontalAlignment: Text.AlignHCenter
              text: modelData
              color: Colors.muted
              opacity: index >= 5 ? 0.6 : 1
              font.family: "monospace"
              font.pixelSize: 11
            }
          }
        }

        Rectangle {
          width: grid.width
          height: 1
          color: Colors.overlay
        }

        Grid {
          id: grid
          columns: 7

          Repeater {
            model: root.cells

            delegate: Item {
              id: cell
              required property var modelData

              width: 36
              height: 32

              Rectangle {
                anchors.centerIn: parent
                width: 28
                height: 28
                radius: 14
                color: cell.modelData.isToday ? Colors.sky : cellHover.hovered ? Colors.overlay : "transparent"
              }

              Text {
                anchors.centerIn: parent
                text: cell.modelData.day
                font.family: "monospace"
                font.pixelSize: 13
                font.bold: cell.modelData.isToday
                color: cell.modelData.isToday ? Colors.base : cell.modelData.weekend ? Colors.muted : Colors.text
                // the neighbouring months are context, not content
                opacity: cell.modelData.inMonth ? 1 : 0.35
              }

              HoverHandler {
                id: cellHover
              }
            }
          }
        }

        Rectangle {
          width: grid.width
          height: 1
          color: Colors.overlay
        }

        // so the card still says where today is while you are reading January
        Text {
          width: grid.width
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatDate(root.today, "dddd d MMMM yyyy")
          color: Colors.muted
          font.family: "monospace"
          font.pixelSize: 11
        }
      }
    }
  }
}
