{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=11";
        };

        # Charing Cross palette -- see CLAUDE.md. foot wants bare hex, no '#'.
        colors-dark = {
          # Glass: the painting shows through, and niri implements
          # ext-background-effect-v1, so the blur is real rather than faked.
          alpha = 0.82;
          blur = "yes";

          background = "0c1a21";
          foreground = "deeaf2";

          regular0 = "14262e"; # black   / fog bank
          regular1 = "cc6a5a"; # red     / ember, dimmed
          regular2 = "6fb08a"; # green   / the halo round the sun
          regular3 = "dbbc84"; # yellow  / sand
          regular4 = "7fb1d8"; # blue    / the Thames
          regular5 = "d98f7d"; # magenta / the sun, dimmed (no purple here)
          regular6 = "86c3c9"; # cyan    / mist
          regular7 = "7fa2ae"; # white   / fog

          bright0 = "23424d";
          bright1 = "e0705a";
          bright2 = "86c6a0";
          bright3 = "ecd0a0";
          bright4 = "9cc6e4";
          bright5 = "f3a48e";
          bright6 = "9fd4d8";
          bright7 = "deeaf2";

          selection-foreground = "0c1a21";
          selection-background = "dbbc84";
        };
      };
    };
  };
}
