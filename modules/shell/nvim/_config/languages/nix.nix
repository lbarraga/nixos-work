{pkgs, ...}: {
  plugins.lsp.servers.nil_ls.enable = true;
  plugins.treesitter.settings.ensure_installed = ["nix"];
  plugins.conform-nvim.settings.formatters_by_ft.nix = ["alejandra"];
  extraPackages = [pkgs.alejandra];
}
