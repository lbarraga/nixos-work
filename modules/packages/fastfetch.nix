{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      settings = {
        # Blue Hour palette -- see CLAUDE.md. fastfetch turns these into
        # truecolor escapes, so the "#rrggbb" form is exact.
        #
        # All three slots are `sky`. That matters: the built-in NixOS logo
        # bakes raw 34/36 escapes into its art that these slots cannot
        # override, and foot maps those two to `sky` and `haze` -- the same
        # blue two steps apart -- so the baked-in blues blend with the ones set
        # here rather than clash.
        logo.color = {
          "1" = "#4fb0f8"; # sky
          "2" = "#4fb0f8";
          "3" = "#4fb0f8";
        };

        display.color = {
          title = "#f0dca0";
          keys = "#5fc9a4";
          separator = "#7d9cc2";
          output = "#e9f4fa";
        };

        # Passing --config replaces fastfetch's built-in config wholesale, so
        # without this list it prints the logo and nothing else. These are the
        # defaults, minus the ones that are noise on a laptop.
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
