{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.fuzzel = inputs.wrapper-modules.wrappers.fuzzel.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=12";
          lines = 10;
          width = 40;
        };
      };
    };
  };
}
