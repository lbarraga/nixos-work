import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

// Replaces mako. mako has no animation support at all, and this lives in the
// quickshell instance that already draws the bar, so one process serves both.
PanelWindow {
  id: root
  required property var modelData
  screen: modelData

  WlrLayershell.layer: WlrLayer.Overlay
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"

  anchors {
    top: true
    right: true
  }

  margins {
    top: 12
    right: 12
  }

  // Sized to the stack, so the layer surface never swallows clicks meant for
  // the window underneath.
  implicitWidth: 400
  implicitHeight: Math.max(1, column.implicitHeight)

  // One server for all screens; only the focused one shows the stack.
  NotificationServer {
    id: server
    keepOnReload: false
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true

    // Without this the server accepts notifications and immediately
    // forgets them: trackedNotifications only holds the ones opted in.
    onNotification: notification => {
      notification.tracked = true;
    }
  }

  Column {
    id: column
    width: parent.width
    spacing: 10

    Repeater {
      model: server.trackedNotifications

      delegate: Rectangle {
        id: card
        required property var modelData

        width: parent.width
        implicitHeight: text.implicitHeight + 28
        radius: 10
        color: "#f014262e"
        border.width: 2
        border.color: modelData.urgency === NotificationUrgency.Critical
          ? "#e0705a"
          : modelData.urgency === NotificationUrgency.Low
            ? "#23424d"
            : "#f3a48e"

        // Slide in from off the right edge, then fade out on the way back.
        x: width
        opacity: 0
        Component.onCompleted: {
          x = 0;
          opacity = 1;
        }
        Behavior on x {
          NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
          }
        }
        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }

        Column {
          id: text
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: 14
          }
          spacing: 4

          Text {
            width: parent.width
            text: card.modelData.summary
            color: "#deeaf2"
            font.family: "monospace"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            visible: card.modelData.body !== ""
            text: card.modelData.body
            color: "#deeaf2"
            font.family: "monospace"
            font.pixelSize: 12
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: card.modelData.dismiss()
        }

        // Critical notifications (poweralertd's low battery) stay until
        // clicked; everything else clears itself.
        Timer {
          running: card.modelData.urgency !== NotificationUrgency.Critical
          interval: 6000
          onTriggered: card.modelData.expire()
        }
      }
    }
  }
}
