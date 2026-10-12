import Quickshell
import QtQuick

PanelWindow {
  required property var modelData
  screen: modelData

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 30

  // Ninth Wave palette -- see CLAUDE.md. Slightly translucent so the painting
  // tints the bar, matching foot's glass.
  color: "#d0232518"

  Text {
    anchors.centerIn: parent
    color: "#efe3c4"
    font.pixelSize: 14
    text: Qt.formatDateTime(clock.date, "HH:mm")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
