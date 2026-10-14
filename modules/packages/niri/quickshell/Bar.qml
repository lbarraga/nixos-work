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

  // Charing Cross palette -- see CLAUDE.md. Slightly translucent so the painting
  // tints the bar, matching foot's glass.
  color: "#d014262e"

  Text {
    anchors.centerIn: parent
    color: "#deeaf2"
    font.pixelSize: 14
    text: Qt.formatDateTime(clock.date, "HH:mm")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
