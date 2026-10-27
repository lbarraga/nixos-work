{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.rmpc = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.rmpc;
      flags = {
        "--config" = ./config.ron;
        "--theme" = ./theme.ron;
      };
    };
  };
}
