{ pkgs, ... }: {
  plugins.telescope = {
    enable = true;

    settings.defaults.mappings.i = {
      "<C-j>" = "move_selection_next";
      "<C-k>" = "move_selection_previous";
    };
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
  ];

  keymaps = [
    {
      mode = "n";
      key = "<leader><space>";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Search text in project";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>Telescope diagnostics<CR>";
      options.desc = "Search diagnostics in project";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Telescope git_status<CR>";
      options.desc = "Git Status Popup";
    }
  ];
}
