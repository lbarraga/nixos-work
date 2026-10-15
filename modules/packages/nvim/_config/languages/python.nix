{
  plugins.lsp.servers.pyright.enable = true;
  plugins.lsp.servers.ruff.enable = true;
  plugins.treesitter.settings.ensure_installed = ["python"];

  plugins.conform-nvim.settings.formatters_by_ft.python = ["ruff_format"];
}
