{ inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
      inherit pkgs;

      # nixos.nix sources this directory's .zshrc into /etc/zshrc,
      # so the name is pinned here rather than left to the wrapper default.
      zdotFilesDirname = "zsh-dot-dir";

      # what the aliases call by name
      runtimePkgs = [ pkgs.eza ];

      zshAliases = {
        ls = "eza --git --icons=auto";
        l = "eza -lah --git --icons=auto";
        ll = "eza -lah --git --icons=auto";
        lt = "eza --tree --git --icons=auto";
        open = "xdg-open";
        nix-shell = "nix-shell --run zsh";
        temp = ''cd "$(mktemp -d)"'';

        # Not in runtimePkgs like eza: fastfetch's closure is 440M, which is
        # not a thing to carry in the shell. shell/cli-tools.nix installs it.
        ff = "fastfetch";
      };

      zshrc.content = ''
        HISTFILE=''${HOME}/.zsh_history
        HISTSIZE=50000
        SAVEHIST=50000
        setopt share_history hist_ignore_dups hist_ignore_space

        # ZDOTDIR is the wrapper's own store directory, and compinit defaults
        # its dump to $ZDOTDIR/.zcompdump — a path nothing can ever write. With
        # no dump it rescans fpath and replays every compdef on each shell:
        # 360ms of a 420ms startup. Point the dump somewhere writable.
        _zcompdump=''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
        [[ -d ''${_zcompdump:h} ]] || mkdir -p ''${_zcompdump:h}
        autoload -Uz compinit && compinit -d $_zcompdump
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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

        ns() { nix shell "''${@/#/nixpkgs#}" }
        nr() { nix run "nixpkgs#$1" -- "''${@:2}" }
        nsu() { nix shell "''${@/#/nixpkgs/nixpkgs-unstable#}" }
        nru() { nix run "nixpkgs/nixpkgs-unstable#$1" -- "''${@:2}" }

        export STARSHIP_CONFIG=${./starship.toml}
        eval "$(${lib.getExe pkgs.starship} init zsh)"
      '';
    };
  };
}
