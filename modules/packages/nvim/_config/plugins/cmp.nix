{
  plugins.lspkind = {
    enable = true;
    cmp.enable = true;
  };

  plugins.luasnip.enable = true;

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      window = {
        completion.border = "rounded";
        documentation.border = "rounded";
      };
      view = {
        docs = {
          auto_open = false;
        };
      };
      sources = [
        {name = "nvim_lsp";}
        {name = "luasnip";}
        {name = "path";}
      ];
      mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<C-j>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        "<C-k>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.abort()";
        "<C-h>" = "cmp.mapping(function() local cmp = require('cmp'); if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end end)";
      };
    };
  };

  extraConfigLua = ''
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  '';
}
