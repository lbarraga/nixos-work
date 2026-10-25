{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=11";
        };

        # Hillside palette -- see CLAUDE.md. foot wants bare hex, no '#'.
        colors-dark = {
          # the blur is real: niri implements ext-background-effect-v1
          alpha = 0.82;
          blur = "yes";

          background = "09180d";
          foreground = "ecf5ed";

          regular0 = "102416"; # black   / the forest floor
          regular1 = "d8655f"; # red     / ember, dimmed
          regular2 = "7cb05e"; # green   / fern, dimmed
          regular3 = "d9b361"; # yellow  / wheat
          regular4 = "46b8d7"; # blue    / the sky over the ridge
          regular5 = "b379c0"; # magenta / bloom, dimmed
          regular6 = "1fbfbf"; # cyan    / aqua, the accent
          regular7 = "80a48e"; # white   / sage on the far hillside

          bright0 = "274a31";
          bright1 = "ee7d76";
          bright2 = "94c976";
          bright3 = "eddda0";
          bright4 = "83d7f2";
          bright5 = "cb90d8";
          bright6 = "79dede";
          bright7 = "ecf5ed";

          selection-foreground = "09180d";
          selection-background = "d9b361";
        };
      };
    };
  };
}
