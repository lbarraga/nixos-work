//@ pragma UseQApplication

import Quickshell
import QtQuick

ShellRoot {
  id: root

  // The bar lives on one screen; the wallpaper and notifications stay on all
  // of them. Quickshell reports an empty serialNumber and the two LG panels
  // share a model string, so the connector name is the only thing that tells
  // them apart. An unknown name -- the laptop, a windowed test, someone else's
  // machine -- falls back to the first screen, so there is always one bar.
  readonly property string mainScreenName: "DP-3"
  readonly property var mainScreen: Quickshell.screens.find(s => s.name === root.mainScreenName) ?? Quickshell.screens[0]

  Variants {
    model: Quickshell.screens

    Wallpaper {}
  }

  Variants {
    model: root.mainScreen ? [root.mainScreen] : []

    Bar {}
  }

  Variants {
    model: Quickshell.screens

    Notifications {}
  }
}
