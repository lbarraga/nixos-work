pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Quickshell 0.3 ships modules for Hyprland and i3 but not niri, so workspace
// state comes from niri's own IPC.
Singleton {
  id: root

  // straight from `niri msg --json workspaces`
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

  // Re-reading the whole list beats replaying events into a local model: a few
  // milliseconds, and it cannot drift out of sync.
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
        // half-read or empty; the next event refreshes anyway
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
      // Window events fire on every title change, which in a terminal means
      // every keystroke.
      onRead: line => {
        if (line.indexOf("Workspace") !== -1)
          debounce.restart();
      }
    }
  }

  Component.onCompleted: root.refresh()
}
