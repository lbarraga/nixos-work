pragma Singleton

import Quickshell
import QtQuick

// Hillside palette -- see CLAUDE.md. Colors, not Palette: QtQuick has a
// built-in Palette value type that wins the lookup silently, resolving every
// color to undefined.
Singleton {
  readonly property color base: "#09180d"
  readonly property color surface: "#102416"
  readonly property color overlay: "#274a31"
  readonly property color muted: "#80a48e"
  readonly property color text: "#ecf5ed"
  readonly property color sun: "#eddda0"
  readonly property color wheat: "#d9b361"
  readonly property color ember: "#ee7d76"
  readonly property color fern: "#94c976"
  readonly property color aqua: "#1fbfbf"
  readonly property color sky: "#83d7f2"
  readonly property color bloom: "#cb90d8"

  // translucent, so the wallpaper tints the bar and the cards
  readonly property color barBackground: "#d0102416"
  readonly property color cardBackground: "#f0102416"

  // the readouts inside the system panel, a shade down so they read as recessed
  readonly property color panelCard: "#7009180d"
}
