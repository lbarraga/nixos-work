# This file adds an animated indicator for the current indentation scope.
{
  plugins.mini = {
    enable = true;
    modules.indentscope = {
      symbol = "│";
      options.try_as_border = true;
      draw.animation.__raw = "require('mini.indentscope').gen_animation.none()";
    };
  };

  extraConfigLua = ''
    -- Aggressively disable the active indent line on specific screens
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
      pattern = { "dashboard", "neo-tree" },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  '';
}
