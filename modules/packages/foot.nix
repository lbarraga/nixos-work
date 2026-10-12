{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=11";
        };

        # Ninth Wave palette -- see CLAUDE.md. foot wants bare hex, no '#'.
        colors-dark = {
          # Glass: the painting shows through, and niri implements
          # ext-background-effect-v1, so the blur is real rather than faked.
          alpha = 0.82;
          blur = "yes";

          background = "14160e";
          foreground = "efe3c4";

          regular0 = "232518"; # black   / surface
          regular1 = "c96a4a"; # red     / rust
          regular2 = "9dbf4e"; # green   / wave crest
          regular3 = "de982d"; # yellow  / amber
          regular4 = "7fb0b3"; # blue    / deep sea
          regular5 = "e8703a"; # magenta / fire (the painting has no purple)
          regular6 = "7fb0b3"; # cyan    / deep sea
          regular7 = "9a8265"; # white   / muted

          bright0 = "3f402b";
          bright1 = "e8703a";
          bright2 = "aaa136";
          bright3 = "f5d62e";
          bright4 = "9dc6c8";
          bright5 = "f28737";
          bright6 = "9dc6c8";
          bright7 = "efe3c4";

          selection-foreground = "14160e";
          selection-background = "de982d";
        };
      };
    };
  };
}
