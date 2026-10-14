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

        # Charing Cross palette -- see CLAUDE.md. fuzzel wants RRGGBBAA.
        colors = {
          background = "14262ef0";
          text = "deeaf2ff";
          prompt = "f3a48eff";
          placeholder = "7fa2aeff";
          input = "deeaf2ff";
          match = "f3a48eff";
          selection = "23424dff";
          selection-text = "deeaf2ff";
          selection-match = "f3a48eff";
        };

        border = {
          width = 2;
          radius = 8;
        };
      };
    };
  };
}
