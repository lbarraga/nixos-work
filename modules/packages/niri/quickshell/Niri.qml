pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Quickshell 0.3 has modules for Hyprland and i3 but not for niri, so the
// workspace state comes from niri's own IPC.
Singleton {
  id: root

  // Straight from `niri msg --json workspaces`: id, idx, name, output,
  // is_active, is_focused, is_urgent, active_window_id.
  property var workspaces: []

  property bool pending: false

  function focusWorkspace(idx) {
    focus.command = ["niri", "msg", "action", "focus-workspace", String(idx)];
    focus.running = true;
  }

  function refresh() {
    if (query.running) root.pending = true;
    else query.running = true;
  }

  Process {
    id: focus
  }

  // Re-reading the whole list beats replaying events into a local model: it is
  // a few milliseconds, it cannot drift out of sync, and it means this file
  // does not need to know the shape of every workspace event niri can send.
  Process {
    id: query
    command: ["niri", "msg", "--json", "workspaces"]
    stdout: StdioCollector {
      id: queryOut
    }
    onExited: {
      try {
        root.workspaces = JSON.parse(queryOut.text);
      } catch (e) {
        // A half-read or empty response: the next event will refresh anyway.
      }
      if (root.pending) {
        root.pending = false;
        query.running = true;
      }
    }
  }

  Timer {
    id: debounce
    interval: 25
    onTriggered: root.refresh()
  }

  Process {
    running: true
    command: ["niri", "msg", "--json", "event-stream"]
    stdout: SplitParser {
      // Only workspace-shaped events. Window events fire on every title
      // change, which inside a terminal means on every keystroke.
      onRead: line => {
        if (line.indexOf("Workspace") !== -1)
          debounce.restart();
      }
    }
  }

  Component.onCompleted: root.refresh()
}
