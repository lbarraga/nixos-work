{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.starship = inputs.wrapper-modules.wrappers.starship.wrap {
      inherit pkgs;
      settings = {
        format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

        directory = {
          style = "bold #4fb0f8";
          format = "[$path]($style) ";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
          };
        };

        git_branch = {
          symbol = " ";
          style = "bold #a99bf2";
          format = "[$symbol$branch]($style) ";
        };

        git_status = {
          style = "bold #dcb169";
          format = "[$all_status$ahead_behind]($style)";
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

        cmd_duration = {
          min_time = 500;
          style = "#7d9cc2";
          format = "[$duration]($style) ";
        };

        character = {
          success_symbol = "[❯](bold #5fc9a4)";
          error_symbol = "[❯](bold #ec7a8c)";
        };
      };
    };
  };
}
