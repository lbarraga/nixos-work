{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages.orca-slicer = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      package = inputs.nixpkgs-unstable.legacyPackages.${system}.orca-slicer;
      env.WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    };
  };
}
