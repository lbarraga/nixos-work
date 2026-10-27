{
  perSystem = { pkgs, ... }: {
    # The treefmt wrapper, not bare nixfmt: `nix fmt` passes no arguments and
    # nixfmt would then read stdin and block.
    formatter = pkgs.nixfmt-tree;
  };
}
