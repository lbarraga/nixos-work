{inputs, ...}: {
  perSystem = {system, ...}: {
    # The only consumer of the unstable input: stable has no brave-origin.
    # Extensions are not set here -- they are an enterprise policy, which is a
    # /etc file and therefore the business of features/brave.nix.
    packages.brave = inputs.nixpkgs-unstable.legacyPackages.${system}.brave-origin.override {
      commandLineArgs = ["--disable-features=WebRtcAllowInputVolumeAdjustment"];
    };
  };
}
