{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    lib,
    ...
  }: {
    packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
      inherit pkgs;

      # features/shell.nix sources this directory's .zshrc into /etc/zshrc,
      # so the name is pinned here rather than left to the wrapper default.
      zdotFilesDirname = "zsh-dot-dir";

      # what the aliases call by name
      runtimePkgs = [pkgs.eza pkgs.xdg-utils];

      zshAliases = {
        ls = "eza --git --icons=auto";
        ll = "eza -lah --git --icons=auto";
        lt = "eza --tree --git --icons=auto";
        open = "xdg-open";
        temp = ''cd "$(mktemp -d)"'';
      };

      zshrc.content = ''
        HISTFILE=''${HOME}/.zsh_history
        HISTSIZE=50000
        SAVEHIST=50000
        setopt share_history hist_ignore_dups hist_ignore_space

        autoload -Uz compinit && compinit
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

        # Blue Hour `muted` -- see CLAUDE.md. The default fg=8 maps to
        # `overlay` in foot, 1.65:1 against the background and barely visible.
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7d9cc2'

        # autosuggestions first: syntax-highlighting wraps the widgets it binds
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        bindkey -e
        bindkey '^o' autosuggest-accept
        bindkey '\e[1;5D' backward-word
        bindkey '\e[1;5C' forward-word
        bindkey '^k' up-line-or-history
        bindkey '^j' down-line-or-history

        eval "$(${lib.getExe config.packages.starship} init zsh)"
      '';
    };
  };
}
