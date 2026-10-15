pragma Singleton

import Quickshell
import QtQuick

// Blue Hour palette -- see CLAUDE.md. Colors, not Palette: QtQuick has a
// built-in Palette value type that wins the lookup silently, resolving every
// color to undefined.
Singleton {
  readonly property color base: "#0a1226"
  readonly property color surface: "#121d36"
  readonly property color overlay: "#24406b"
  readonly property color muted: "#7d9cc2"
  readonly property color text: "#e9f4fa"
  readonly property color glow: "#f0dca0"
  readonly property color sand: "#dcb169"
  readonly property color rose: "#ec7a8c"
  readonly property color mint: "#5fc9a4"
  readonly property color sky: "#4fb0f8"
  readonly property color haze: "#7fd8f2"
  readonly property color iris: "#a99bf2"

  // translucent, so the wallpaper tints the bar and the cards
  readonly property color barBackground: "#d0121d36"
  readonly property color cardBackground: "#f0121d36"
}
