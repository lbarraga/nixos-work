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

        # Blue Hour palette -- see CLAUDE.md. fuzzel wants RRGGBBAA.
        colors = {
          background = "121d36f0";
          text = "e9f4faff";
          prompt = "4fb0f8ff";
          placeholder = "7d9cc2ff";
          input = "e9f4faff";
          match = "4fb0f8ff";
          selection = "24406bff";
          selection-text = "e9f4faff";
          selection-match = "4fb0f8ff";
        };

        border = {
          width = 2;
          radius = 8;
        };
      };
    };
  };
}
