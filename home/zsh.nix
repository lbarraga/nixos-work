{
  home.sessionVariables = {
    NH_FLAKE = "/home/lukasbt/nix-config";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nix-shell = "nix-shell --run zsh";
      ls = "eza";
      ll = "eza -lah";
      lt = "eza --tree";
      open = "xdg-open";
      temp = "cd \"$(mktemp -d)\"";
    };

    initContent = ''
      setopt interactive_comments
      zstyle ':completion:*' menu select
      bindkey '\e[1;5D' backward-word
      bindkey '\e[1;5C' forward-word
      bindkey '^o' autosuggest-accept
      bindkey '^k' up-line-or-history
      bindkey '^j' down-line-or-history
    '';
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = "[](blue)$os$username[](bg:white fg:blue)$directory[](fg:white bg:cyan)$git_branch$git_status[](fg:cyan bg:bright-black)$docker_context$conda$pixi$aws[](fg:bright-black)";

      right_format = "[](fg:cyan)$c$python$elixir$elm$golang$haskell$java$julia$nodejs$nim$rust$scala[](fg:white bg:cyan)$cmd_duration[](fg:blue bg:white)$character[](fg:blue)";

      os = {
        disabled = false;
        style = "bg:blue fg:white";
        symbols.NixOS = " ";
      };

      username = {
        show_always = false;
        style_user = "bg:blue fg:white";
        style_root = "bg:red fg:white";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "fg:black bg:white";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol $branch ](fg:black bg:cyan)]($style)";
      };

      git_status = {
        style = "bg:cyan";
        format = "[[($all_status$ahead_behind )](fg:black bg:cyan)]($style)";
        untracked = "?\${count} ";
        stashed = "$\${count} ";
        modified = "!\${count} ";
        staged = "+\${count} ";
        renamed = "»\${count} ";
        deleted = "✘\${count} ";
        conflicted = "=\${count} ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count} ⇣\${behind_count} ";
      };

      gcloud = {
        disabled = true;
      };

      aws = {
        symbol = " ";
        style = "bg:bright-black fg:white";
        format = "[$symbol( $profile) ]($style)";
      };

      # Programming Language Modules
      nodejs = {
        symbol = " ";
        style = "bg:cyan fg:black";
        format = "[$symbol($version)]($style)";
      };

      rust = {
        symbol = "󱘗 ";
        style = "bg:cyan fg:black";
        format = "[$symbol($version) ]($style)";
      };

      python = {
        symbol = " ";
        style = "bg:cyan fg:black";
        format = "[$symbol($version) ]($style)";
        detect_files = [];
        detect_extensions = [];
      };

      docker_context = {
        symbol = " ";
        style = "bg:bright-black fg:white";
        format = "[$symbol( $context) ]($style)";
      };

      cmd_duration = {
        min_time = 500;
        format = "[$duration ](bg:white fg:black)";
      };

      character = {
        format = "$symbol";
        success_symbol = "[✔](bold black bg:blue)";
        error_symbol = "[✖](bold black bg:blue)";
      };
    };
  };
}
