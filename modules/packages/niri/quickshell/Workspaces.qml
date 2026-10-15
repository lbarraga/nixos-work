import QtQuick

// One pill per workspace on this screen. Click to focus.
Row {
  id: root

  // the wayland output name, so the laptop bar does not list the dock's
  // workspaces
  required property string screenName

  spacing: 4
  height: 18

  readonly property var list: (Niri.workspaces || []).filter(w => !root.screenName || !w.output || w.output === root.screenName).sort((a, b) => a.idx - b.idx)

  Repeater {
    model: root.list

    delegate: Rectangle {
      id: pill
      required property var modelData

      readonly property bool occupied: modelData.active_window_id !== null && modelData.active_window_id !== undefined

      width: Math.max(20, label.implicitWidth + 12)
      height: 18
      radius: 9

      color: modelData.is_urgent ? Colors.rose : modelData.is_active ? Colors.sky : pill.occupied ? Colors.overlay : "transparent"

      // empty ones get an outline rather than a fill
      border.width: !pill.occupied && !modelData.is_active && !modelData.is_urgent ? 1 : 0
      border.color: Colors.overlay

      Text {
        id: label
        anchors.centerIn: parent
        text: modelData.name ? modelData.name : modelData.idx
        color: modelData.is_active || modelData.is_urgent ? Colors.base : pill.occupied ? Colors.text : Colors.muted
        font.family: "monospace"
        font.pixelSize: 12
        font.bold: modelData.is_active
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Niri.focusWorkspace(pill.modelData.idx)
      }

      Behavior on color {
        ColorAnimation {
          duration: 120
        }
      }
    }
  }
}
