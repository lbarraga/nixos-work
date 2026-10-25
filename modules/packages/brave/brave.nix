{inputs, ...}: {
  perSystem = {system, ...}: {
    packages.brave = inputs.nixpkgs-unstable.legacyPackages.${system}.brave-origin.override {
      commandLineArgs = ["--disable-features=WebRtcAllowInputVolumeAdjustment"];
    };
  };
}
