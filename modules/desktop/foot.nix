{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=11";
        };

        # Blue Hour palette -- see CLAUDE.md. foot wants bare hex, no '#'.
        colors-dark = {
          # the blur is real: niri implements ext-background-effect-v1
          alpha = 0.82;
          blur = "yes";

          background = "0a1226";
          foreground = "e9f4fa";

          regular0 = "121d36"; # black   / the far ridge
          regular1 = "d26a7c"; # red     / rose, dimmed
          regular2 = "4fb492"; # green   / mint, dimmed
          regular3 = "dcb169"; # yellow  / sand
          regular4 = "4fb0f8"; # blue    / the sky
          regular5 = "9385dc"; # magenta / iris, dimmed
          regular6 = "5fc2df"; # cyan    / haze, dimmed
          regular7 = "7d9cc2"; # white   / the haze on the ridge line

          bright0 = "24406b";
          bright1 = "ec7a8c";
          bright2 = "5fc9a4";
          bright3 = "f0dca0";
          bright4 = "7fc4ff";
          bright5 = "a99bf2";
          bright6 = "7fd8f2";
          bright7 = "e9f4fa";

          selection-foreground = "0a1226";
          selection-background = "dcb169";
        };
      };
    };
  };
}
