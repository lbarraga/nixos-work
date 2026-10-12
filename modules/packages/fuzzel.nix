{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.fuzzel = inputs.wrapper-modules.wrappers.fuzzel.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=12";
          lines = 10;
          width = 40;
        };

        # Ninth Wave palette -- see CLAUDE.md. fuzzel wants RRGGBBAA.
        colors = {
          background = "232518f0";
          text = "efe3c4ff";
          prompt = "f5d62eff";
          placeholder = "9a8265ff";
          input = "efe3c4ff";
          match = "f5d62eff";
          selection = "3f402bff";
          selection-text = "efe3c4ff";
          selection-match = "f5d62eff";
        };

        border = {
          width = 2;
          radius = 8;
        };
      };
    };
  };
}
