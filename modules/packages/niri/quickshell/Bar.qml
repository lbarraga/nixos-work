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
  color: "#1e1e2e"

  Text {
    anchors.centerIn: parent
    color: "#cdd6f4"
    font.pixelSize: 14
    text: Qt.formatDateTime(clock.date, "HH:mm")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
