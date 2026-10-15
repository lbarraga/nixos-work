# This file adds a floating window for full git repository management.
{
  plugins.lazygit.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Open LazyGit";
    }
  ];
}
