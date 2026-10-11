{
  flake.modules.nixos.claude-code = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = [ pkgs.claude-code ];
  };
}
