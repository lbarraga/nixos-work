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

        # Hillside palette -- see CLAUDE.md. fuzzel wants RRGGBBAA.
        colors = {
          background = "102416f0";
          text = "ecf5edff";
          prompt = "1fbfbfff";
          placeholder = "80a48eff";
          input = "ecf5edff";
          match = "1fbfbfff";
          selection = "274a31ff";
          selection-text = "ecf5edff";
          selection-match = "1fbfbfff";
        };

        border = {
          width = 2;
          radius = 8;
        };
      };
    };
  };
}
