# This file configures the sidebar file explorer.
{
  plugins.neo-tree = {
    enable = true;
    settings = {
      close_if_last_window = true;
      window.mappings = {
        "l" = "open";
        "h" = "close_node";
      };
      filesystem.follow_current_file = {
        enabled = true;
        leave_dirs_open = true;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options.desc = "Toggle File Explorer";
    }
  ];
}
