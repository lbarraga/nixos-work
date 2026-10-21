{self, ...}: {
  flake.modules.nixos.shell = {
    pkgs,
    lib,
    ...
  }: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};

    # The store path, not the package. NixOS rewrites a shell *package* to
    # `/run/current-system/sw/bin/zsh`, which is the plain zsh that
    # programs.zsh installs -- the wrapper would never run.
    zsh = "${mine.zsh}/bin/zsh";
  in {
    programs.zsh = {
      enable = true;
      autosuggestions.enable = false;
      syntaxHighlighting.enable = false;

      # keeps /share/zsh linked and nix-zsh-completions installed, so fpath
      # still sees system completions
      enableCompletion = true;

      # ...but not the compinit call in /etc/zshrc; the package runs its own
      enableGlobalCompInit = false;

      # NixOS runs `prompt suse` after interactiveShellInit, overwriting
      # whatever starship set up.
      promptInit = "";

      # The config lives in the zsh package so it also works over ssh on a
      # machine that is not NixOS. /etc/zshrc sources that same file, so a
      # shell started as /run/current-system/sw/bin/zsh -- sudo -s, a nix
      # shell, anything reading a stale $SHELL -- is configured too, not just
      # a fresh login on the wrapper. The file guards itself against being
      # sourced twice, so the wrapper's own copy then returns early.
      interactiveShellInit = lib.mkAfter ''
        source ${mine.zsh}/zsh-dot-dir/.zshrc
      '';
    };

    environment.shells = [zsh];
    users.users.lukasbt.shell = zsh;

    # what the aliases call by name
    environment.systemPackages = [pkgs.eza pkgs.xdg-utils];
  };
}
