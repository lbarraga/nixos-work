# This file sets the global keyboard shortcuts.
{
  keymaps = [
    {
      mode = "i";
      key = "jk";
      action = "<Esc>";
      options.desc = "Escape insert mode";
    }
    {
      mode = ["n" "i" "v"];
      key = "<C-s>";
      action = "<cmd>w<cr><esc>";
      options.desc = "Save file";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Go to left window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Go to right window";
    }
    {
      mode = "n";
      key = "qq";
      action = "<cmd>qa<cr>";
      options.desc = "Quit all";
    }
    {
      mode = "n";
      key = "<leader>R";
      action = "gg\"_dGP";
      options.desc = "Replace whole file with clipboard";
    }
  ];
}
