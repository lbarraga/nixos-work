# Sets the basic editor rules and display settings.
{
  vimAlias = true;
  viAlias = true;

  dependencies = {
    gcc.enable = true;
  };

  opts = {
    showmode = false;
    cmdheight = 0;
    number = true;
    relativenumber = true;
    pumheight = 5;
    undofile = true;
    autoindent = true;
    smartindent = true;
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";

    # folding
    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    foldlevel = 99;
  };

  diagnostic = {
    settings = {
      virtual_text = {
        prefix = "●";
        spacing = 4;
      };
      signs = true;
      underline = true;
      severity_sort = true;
    };
  };

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight when yanking (copying) text",
      callback = function()
        vim.highlight.on_yank({ timeout = 200 })
      end,
    })
  '';

  globals.mapleader = " ";
  clipboard.register = "unnamedplus";
}
