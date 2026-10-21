{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      settings = {
        # Blue Hour palette -- see CLAUDE.md. All three slots are `sky`: the
        # NixOS logo bakes raw 34/36 escapes into its art that these cannot
        # override, and foot maps those to sky and haze anyway.
        logo.color = {
          "1" = "#4fb0f8"; # sky
          "2" = "#4fb0f8";
          "3" = "#4fb0f8";
        };

        display.color = {
          title = "#4fb0f8";
          keys = "#5fc9a4";
          separator = "#7d9cc2";
          output = "#e9f4fa";
        };

        # --config replaces the built-in config wholesale, so without this it
        # prints the logo and nothing else. The defaults, minus the noise.
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "wm"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "battery"
          "break"
          "colors"
        ];
      };
    };
  };
}
