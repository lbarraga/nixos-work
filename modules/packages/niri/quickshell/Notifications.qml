import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

// Replaces mako, which cannot animate, and shares the quickshell instance
// that already draws the bar.
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

  // sized to the stack, so the surface does not swallow clicks beneath it
  implicitWidth: 400
  implicitHeight: Math.max(1, column.implicitHeight)

  // one server for all screens; only the focused one shows the stack
  NotificationServer {
    id: server
    keepOnReload: false
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true

    // without this the server accepts notifications and forgets them at once
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
        implicitHeight: content.implicitHeight + 28
        radius: 10
        color: Colors.cardBackground
        border.width: 2
        border.color: modelData.urgency === NotificationUrgency.Critical
          ? Colors.rose
          : modelData.urgency === NotificationUrgency.Low
            ? Colors.overlay
            : Colors.glow

        // slide in from off the right edge, fade out on the way back
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

        // declared before the content, so the action buttons sit on top of it
        // and take their own clicks
        MouseArea {
          anchors.fill: parent
          onClicked: card.modelData.dismiss()
        }

        Column {
          id: content
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
            color: Colors.text
            font.family: "monospace"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            visible: card.modelData.body !== ""
            text: card.modelData.body
            color: Colors.text
            font.family: "monospace"
            font.pixelSize: 12
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
          }

          // the buttons a pairing request or a "reply" notification carries.
          // Without these the card is unanswerable: blueman's confirmation
          // waits on an action it has no way to receive.
          Row {
            spacing: 8
            topPadding: 6
            visible: card.modelData.actions.length > 0

            Repeater {
              model: card.modelData.actions

              delegate: Rectangle {
                id: button
                required property var modelData

                implicitWidth: label.implicitWidth + 20
                implicitHeight: label.implicitHeight + 10
                radius: 6
                color: area.containsMouse ? Colors.overlay : Colors.surface
                border.width: 1
                border.color: area.containsMouse ? Colors.glow : Colors.overlay

                Text {
                  id: label
                  anchors.centerIn: parent
                  // the spec's "default" action is the whole-card click, not a
                  // button, and its text is conventionally empty
                  text: button.modelData.text !== ""
                    ? button.modelData.text
                    : button.modelData.identifier
                  color: area.containsMouse ? Colors.glow : Colors.text
                  font.family: "monospace"
                  font.pixelSize: 12
                }

                MouseArea {
                  id: area
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    button.modelData.invoke();
                    if (!card.modelData.resident)
                      card.modelData.dismiss();
                  }
                }
              }
            }
          }
        }

        // critical ones (poweralertd's low battery) stay until clicked, and so
        // does anything waiting on an answer or asking for no timeout
        Timer {
          running: card.modelData.urgency !== NotificationUrgency.Critical
            && card.modelData.actions.length === 0
            && card.modelData.expireTimeout !== 0
          interval: card.modelData.expireTimeout > 0
            ? card.modelData.expireTimeout * 1000
            : 6000
          onTriggered: card.modelData.expire()
        }
      }
    }
  }
}
