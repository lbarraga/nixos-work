{ self, ... }: {
  flake.modules.nixos.shell = { pkgs, lib, ... }:
    let
      mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;

        # Blue Hour `muted` -- see CLAUDE.md. The default fg=8 maps to
        # `overlay` in foot, 1.65:1 against the background and barely visible.
        autosuggestions.highlightStyle = "fg=#7d9cc2";
        syntaxHighlighting.enable = true;
        histSize = 50000;

        # NixOS runs `prompt suse` after interactiveShellInit, overwriting
        # whatever starship set up.
        promptInit = "";

        shellAliases = {
          ls = "eza --git --icons=auto";
          ll = "eza -lah --git --icons=auto";
          lt = "eza --tree --git --icons=auto";
          open = "xdg-open";
          temp = ''cd "$(mktemp -d)"'';
          nix-shell = "nix-shell --run zsh";
        };

        # mkAfter: autosuggest-accept only exists once the plugin is sourced
        interactiveShellInit = lib.mkAfter ''
          zstyle ':completion:*' menu select
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

          bindkey '^o' autosuggest-accept
          bindkey '\e[1;5D' backward-word
          bindkey '\e[1;5C' forward-word
          bindkey '^k' up-line-or-history
          bindkey '^j' down-line-or-history

          eval "$(${lib.getExe mine.starship} init zsh)"
        '';
      };

      # what the aliases call by name
      environment.systemPackages = [ pkgs.eza pkgs.xdg-utils ];

      users.users.lukasbt.shell = pkgs.zsh;
    };
}
