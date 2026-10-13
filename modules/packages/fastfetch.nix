{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      settings = {
        # Ninth Wave palette -- see CLAUDE.md. fastfetch turns these into
        # truecolor escapes, so the "#rrggbb" form is exact.
        #
        # All three slots are `sea`, which is also where foot maps ANSI blue
        # and cyan. That matters: the built-in NixOS logo bakes raw 34/36
        # escapes into its art that these slots cannot override, and this is
        # the one color choice that makes them blend in rather than clash.
        logo.color = {
          "1" = "#7fb0b3"; # sea
          "2" = "#7fb0b3";
          "3" = "#7fb0b3";
        };

        display.color = {
          title = "#f5d62e";
          keys = "#9dbf4e";
          separator = "#9a8265";
          output = "#efe3c4";
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
