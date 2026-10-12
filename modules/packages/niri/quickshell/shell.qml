import Quickshell
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens

    Wallpaper {}
  }

  Variants {
    model: Quickshell.screens

    Bar {}
  }
}
