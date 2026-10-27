{
  plugins.flash.enable = true;

  keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<cmd>lua require('flash').jump()<cr>";
      options.desc = "Flash Jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action = "<cmd>lua require('flash').treesitter()<cr>";
      options.desc = "Flash Treesitter";
    }
    {
      mode = "o";
      key = "r";
      action = "<cmd>lua require('flash').remote()<cr>";
      options.desc = "Remote Flash";
    }
    {
      mode = [
        "o"
        "x"
      ];
      key = "R";
      action = "<cmd>lua require('flash').treesitter_search()<cr>";
      options.desc = "Treesitter Search";
    }
  ];
}
