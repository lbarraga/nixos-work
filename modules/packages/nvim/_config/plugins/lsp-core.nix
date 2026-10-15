{pkgs, ...}: {
  extraPackages = [pkgs.tree-sitter];

  plugins = {
    lsp.enable = true;

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 500;
        };
      };
    };

    treesitter = {
      enable = true;
      settings.highlight.enable = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "gd";
      action = "<cmd>Telescope lsp_definitions<cr>";
      options.desc = "Goto Definition";
    }
    {
      mode = "n";
      key = "grr";
      action = "<cmd>Telescope lsp_references<cr>";
      options.desc = "List References";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Code Action";
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options.desc = "Line Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options.desc = "Rename Symbol";
    }
    {
      mode = "n";
      key = "<C-space>";
      action = "van";
      options.remap = true;
      options.desc = "Start selection";
    }
    {
      mode = "x";
      key = "<C-space>";
      action = "an";
      options.remap = true;
      options.desc = "Grow selection";
    }
    {
      mode = "x";
      key = "<BS>";
      action = "in";
      options.remap = true;
      options.desc = "Shrink selection";
    }
  ];
}
