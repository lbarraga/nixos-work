{
  # Rustaceanvim for the language server, type hints, and enabling all cargo features
  plugins.rustaceanvim = {
    enable = true;
    settings = {
      server = {
        default_settings = {
          "rust-analyzer" = {
            cargo = {
              allFeatures = true;
            };
            check = {
              command = "clippy";
            };
          };
        };
      };
    };
  };

  # Crates plugin for dependency management
  plugins.crates = {
    enable = true;
  };

  # Add crates to the autocompletion sources
  plugins.cmp.settings.sources = [
    {name = "crates";}
  ];

  # Syntax highlighting
  plugins.treesitter.settings.ensure_installed = ["rust"];

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end,
    })

    -- Route Rust buffers to rustaceanvim's renderers instead of the generic LSP ones.
    -- Same server, same requests -- these just stop discarding rust-analyzer's extra data.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function(ev)
        local map = function(key, cmd, desc)
          vim.keymap.set("n", key, "<cmd>RustLsp " .. cmd .. "<cr>", { buffer = ev.buf, desc = desc })
        end
        map("K", "hover actions", "Hover actions")
        map("<leader>ca", "codeAction", "Code Action (grouped)")
        map("<leader>cd", "renderDiagnostic", "Diagnostic (full rustc render)")
        map("<leader>ce", "explainError", "Explain error (rustc --explain)")
        map("<leader>cm", "expandMacro", "Expand macro")
      end,
    })
  '';
}
