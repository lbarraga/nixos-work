{
  perSystem = {pkgs, ...}: {
    # `nix fmt` with no arguments passes none on, and alejandra then reads
    # stdin and blocks. Default it to the whole tree.
    formatter = pkgs.writeShellApplication {
      name = "alejandra-tree";
      runtimeInputs = [pkgs.alejandra];
      text = ''alejandra "''${@:-.}"'';
    };
  };
}
