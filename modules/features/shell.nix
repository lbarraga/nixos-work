{ self, ... }: {
  flake.modules.nixos.shell = { pkgs, lib, ... }:
    let
      mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;

        # Charing Cross palette -- see CLAUDE.md. The default is "fg=8",
        # ANSI bright black, which foot maps to `overlay`: 1.65:1 on the
        # terminal background, so the suggestion is barely visible. `muted` is
        # the palette's inactive-text color and clears WCAG AA at 6.5:1.
        autosuggestions.highlightStyle = "fg=#7fa2ae";
        syntaxHighlighting.enable = true;
        histSize = 50000;

        # NixOS runs `prompt suse` after interactiveShellInit, which overwrites
        # whatever starship just set up.
        promptInit = "";

        shellAliases = {
          ls = "eza --git --icons=auto";
          ll = "eza -lah --git --icons=auto";
          lt = "eza --tree --git --icons=auto";
          open = "xdg-open";
          temp = ''cd "$(mktemp -d)"'';
          nix-shell = "nix-shell --run zsh";
        };

        # mkAfter so this lands after the plugin modules: autosuggest-accept
        # only exists once zsh-autosuggestions has been sourced.
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

      # Programs the aliases call by name.
      environment.systemPackages = [ pkgs.eza pkgs.xdg-utils ];

      users.users.lukasbt.shell = pkgs.zsh;
    };
}
