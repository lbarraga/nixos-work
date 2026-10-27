import Quickshell
import QtQuick

PanelWindow {
  id: bar

  required property var modelData
  screen: modelData

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 30

  // translucent, so the wallpaper tints the bar like it does foot
  color: Colors.barBackground

  Workspaces {
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    screenName: bar.modelData.name
  }

  ClockWidget {
    anchors.centerIn: parent
    screenInfo: bar.modelData
  }

  Row {
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    spacing: 12

    TrayWidget {
      id: tray
      anchors.verticalCenter: parent.verticalCenter
    }

    // separates other people's icons from our readouts. Hidden with the tray,
    // so an empty tray leaves no orphan line.
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 1
      height: 16
      color: Colors.muted
      opacity: 0.3
      visible: tray.visible
    }

    SystemWidget {
      anchors.verticalCenter: parent.verticalCenter
      screenInfo: bar.modelData
    }

    DndWidget {
      anchors.verticalCenter: parent.verticalCenter
    }

    BluetoothWidget {
      anchors.verticalCenter: parent.verticalCenter
    }

    NetworkWidget {
      anchors.verticalCenter: parent.verticalCenter
    }

    BatteryWidget {
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
