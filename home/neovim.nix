{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.my-neovim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
