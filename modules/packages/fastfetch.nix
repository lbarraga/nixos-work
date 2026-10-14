{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      settings = {
        # Charing Cross palette -- see CLAUDE.md. fastfetch turns these into
        # truecolor escapes, so the "#rrggbb" form is exact.
        #
        # All three slots are `thames`. That matters: the built-in NixOS logo
        # bakes raw 34/36 escapes into its art that these slots cannot
        # override, and foot maps those two to `thames` and `mist` -- the same
        # stretch of river a shade apart -- so the baked-in blues blend with
        # the ones set here rather than clash.
        logo.color = {
          "1" = "#7fb1d8"; # thames
          "2" = "#7fb1d8";
          "3" = "#7fb1d8";
        };

        display.color = {
          title = "#f3a48e";
          keys = "#6fb08a";
          separator = "#7fa2ae";
          output = "#deeaf2";
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
