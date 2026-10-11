{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = {
        main = {
          font = "monospace:size=11";
        };
      };
    };
  };
}
