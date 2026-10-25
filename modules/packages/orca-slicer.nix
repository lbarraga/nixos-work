{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # The second consumer of the unstable input: stable is still on 2.3.2.
    #
    # Wrapped rather than used bare because WebKitGTK's DMA-BUF renderer
    # cannot allocate GBM buffers on the NVIDIA driver, and OrcaSlicer draws
    # its home page, setup wizard and most dialogs in a webview -- they all
    # come up blank. A wrapper rather than overrideAttrs so the binary cache
    # still applies; this is a large C++ build.
    packages.orca-slicer = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      package = inputs.nixpkgs-unstable.legacyPackages.${system}.orca-slicer;
      env.WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    };
  };
}
