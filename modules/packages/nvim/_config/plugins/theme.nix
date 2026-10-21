# Blue Hour palette -- see CLAUDE.md. The only file in the editor that names a
# color. base16 for the sixteen slots every plugin integration understands,
# then a Lua pass for the glass. Floats stay solid on `surface`, like the bar.
{
  colorschemes.base16 = {
    enable = true;

    # base04/06/07 repeat: the palette has one step between comment and
    # foreground, not three. base0F has no hue of its own, so it borrows sand.
    colorscheme = {
      base00 = "#0a1226"; # base    -- background
      base01 = "#121d36"; # surface -- cursor line, panels
      base02 = "#24406b"; # overlay -- selection
      base03 = "#7d9cc2"; # muted   -- comments
      base04 = "#7d9cc2"; # muted
      base05 = "#e9f4fa"; # text    -- foreground
      base06 = "#e9f4fa"; # text
      base07 = "#e9f4fa"; # text
      base08 = "#ec7a8c"; # rose    -- variables, errors
      base09 = "#dcb169"; # sand    -- numbers, constants
      base0A = "#f0dca0"; # glow    -- types, search
      base0B = "#5fc9a4"; # mint    -- strings, added
      base0C = "#7fd8f2"; # haze    -- escapes, support
      base0D = "#4fb0f8"; # sky     -- functions
      base0E = "#a99bf2"; # iris    -- keywords
      base0F = "#dcb169"; # sand    -- specials
    };
  };

  # lualine builds its groups from a theme table, so the glass pass cannot
  # reach it. Section c is the fill that spans the window, hence bg = NONE.
  plugins.lualine.settings.options.theme = {
    normal = {
      a = {
        fg = "#0a1226";
        bg = "#4fb0f8";
        gui = "bold";
      };
      b = {
        fg = "#e9f4fa";
        bg = "#121d36";
      };
      c = {
        fg = "#7d9cc2";
        bg = "NONE";
      };
    };
    insert.a = {
      fg = "#0a1226";
      bg = "#5fc9a4";
      gui = "bold";
    };
    visual.a = {
      fg = "#0a1226";
      bg = "#a99bf2";
      gui = "bold";
    };
    replace.a = {
      fg = "#0a1226";
      bg = "#ec7a8c";
      gui = "bold";
    };
    command.a = {
      fg = "#0a1226";
      bg = "#7fd8f2";
      gui = "bold";
    };
    inactive = {
      a = {
        fg = "#7d9cc2";
        bg = "NONE";
      };
      b = {
        fg = "#7d9cc2";
        bg = "NONE";
      };
      c = {
        fg = "#7d9cc2";
        bg = "NONE";
      };
    };
  };

  extraConfigLua = ''
    local blue_hour = {
      base = "#0a1226",
      surface = "#121d36",
      overlay = "#24406b",
      muted = "#7d9cc2",
      text = "#e9f4fa",
      glow = "#f0dca0",
      sand = "#dcb169",
      rose = "#ec7a8c",
      mint = "#5fc9a4",
      sky = "#4fb0f8",
      haze = "#7fd8f2",
      iris = "#a99bf2",
    }

    -- nvim hands backgrounds back as numbers.
    local BASE = tonumber("0a1226", 16)

    local function set(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end

    -- foot only alpha-blends cells carrying the default background, so an
    -- explicit #0a1226 is an opaque block on the glass. base16 paints base00
    -- onto dozens of groups, hence a sweep rather than a list.
    --
    -- Links are left alone so they keep following their source. That is what
    -- makes this hold for lazy plugins: neo-tree links NeoTreeGitAdded to
    -- GitGutterAdd when the tree first opens, and inherits the fix.
    local function unbackground_default()
      for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if not hl.link and hl.bg == BASE then
          hl.bg = nil
          hl.ctermbg = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
    end

    local function blue_hour_overrides()
      unbackground_default()

      -- The window
      set("LineNr", { fg = blue_hour.overlay })
      set("CursorLineNr", { fg = blue_hour.sky, bold = true })
      set("EndOfBuffer", { fg = blue_hour.overlay })
      set("WinSeparator", { fg = blue_hour.overlay })
      set("VertSplit", { fg = blue_hour.overlay })
      set("Visual", { bg = blue_hour.overlay })
      set("Search", { fg = blue_hour.base, bg = blue_hour.sky })
      set("IncSearch", { fg = blue_hour.base, bg = blue_hour.haze })
      set("CurSearch", { fg = blue_hour.base, bg = blue_hour.haze })
      set("MatchParen", { fg = blue_hour.sky, bold = true, underline = true })
      set("LspInlayHint", { fg = blue_hour.muted, italic = true })

      -- active scope one step brighter than the passive guides
      set("IblIndent", { fg = blue_hour.overlay })
      set("IblScope", { fg = blue_hour.muted })
      set("MiniIndentscopeSymbol", { fg = blue_hour.muted })

      -- floats: solid surface, overlay border, warm title
      set("NormalFloat", { fg = blue_hour.text, bg = blue_hour.surface })
      set("FloatBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("FloatTitle", { fg = blue_hour.sky, bg = blue_hour.surface, bold = true })
      set("Pmenu", { fg = blue_hour.text, bg = blue_hour.surface })
      set("PmenuSel", { fg = blue_hour.text, bg = blue_hour.overlay, bold = true })
      set("PmenuSbar", { bg = blue_hour.surface })
      set("PmenuThumb", { bg = blue_hour.overlay })
      set("NotifyBackground", { bg = blue_hour.surface })

      -- noice does not route all its floats through NormalFloat.
      set("NoiceCmdlinePopup", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoiceCmdlinePopupBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("NoiceCmdlinePopupTitle", { fg = blue_hour.sky, bg = blue_hour.surface, bold = true })
      set("NoiceCmdlineIcon", { fg = blue_hour.sky })
      set("NoiceCmdlinePrompt", { fg = blue_hour.sky })
      set("NoicePopup", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoicePopupBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("NoiceConfirm", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoiceConfirmBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })

      -- One panel, not four. base16's integration gives the three windows
      -- different backgrounds and inverts the titles into blocks, one of them
      -- surface-on-surface and so invisible. Here the borders do the dividing
      -- and only the selected row gets a background.
      local panel = { fg = blue_hour.text, bg = blue_hour.surface }
      local border = { fg = blue_hour.overlay, bg = blue_hour.surface }

      set("TelescopeNormal", panel)
      set("TelescopeBorder", border)
      set("TelescopeTitle", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopePromptNormal", panel)
      set("TelescopePromptBorder", border)
      set("TelescopePromptTitle", { fg = blue_hour.sky, bg = blue_hour.surface, bold = true })
      set("TelescopePromptPrefix", { fg = blue_hour.sky, bg = blue_hour.surface })
      set("TelescopePromptCounter", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopeResultsNormal", panel)
      set("TelescopeResultsBorder", border)
      set("TelescopeResultsTitle", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopePreviewNormal", panel)
      set("TelescopePreviewBorder", border)
      set("TelescopePreviewTitle", { fg = blue_hour.sky, bg = blue_hour.surface, bold = true })
      set("TelescopePreviewLine", { bg = blue_hour.overlay })
      set("TelescopePreviewMatch", { fg = blue_hour.base, bg = blue_hour.sky })

      set("TelescopeSelection", { fg = blue_hour.text, bg = blue_hour.overlay, bold = true })
      set("TelescopeSelectionCaret", { fg = blue_hour.sky, bg = blue_hour.overlay })
      set("TelescopeMultiSelection", { fg = blue_hour.iris })
      set("TelescopeMultiIcon", { fg = blue_hour.iris })
      set("TelescopeMatching", { fg = blue_hour.sky, bold = true })

      -- otherwise these inherit DiffAdd's line-blend bg and stripe the list
      set("TelescopeResultsDiffAdd", { fg = blue_hour.mint })
      set("TelescopeResultsDiffChange", { fg = blue_hour.sand })
      set("TelescopeResultsDiffDelete", { fg = blue_hour.rose })
      set("TelescopeResultsDiffUntracked", { fg = blue_hour.muted })

      -- gitsigns builds its staged groups on first attach, after the sweep
      -- has run, so the sweep cannot catch them. Defining them up front does:
      -- gitsigns, like neo-tree, only fills in groups left empty.
      --
      -- Staged goes muted; the sign character already says which kind it is.
      local git_signs = {
        Add = blue_hour.mint,
        Change = blue_hour.sand,
        Changedelete = blue_hour.sand,
        Delete = blue_hour.rose,
        Topdelete = blue_hour.rose,
        Untracked = blue_hour.haze,
      }
      for kind, color in pairs(git_signs) do
        for _, suffix in ipairs({ "", "Cul", "Nr" }) do
          set("GitSigns" .. kind .. suffix, { fg = color })
          set("GitSignsStaged" .. kind .. suffix, { fg = blue_hour.muted })
        end
      end

      -- neo-tree hardcodes off-palette greys and an orange for any group a
      -- colorscheme leaves empty, so these win even though it loads later.
      set("NeoTreeNormal", { fg = blue_hour.text })
      set("NeoTreeNormalNC", { fg = blue_hour.text })
      set("NeoTreeEndOfBuffer", { fg = blue_hour.overlay })
      set("NeoTreeWinSeparator", { fg = blue_hour.overlay })
      set("NeoTreeVertSplit", { fg = blue_hour.overlay })
      set("NeoTreeRootName", { fg = blue_hour.sky, bold = true })
      set("NeoTreeFileName", { fg = blue_hour.text })
      set("NeoTreeFileNameOpened", { fg = blue_hour.text, bold = true })
      set("NeoTreeDirectoryName", { fg = blue_hour.sky })
      set("NeoTreeDirectoryIcon", { fg = blue_hour.sky })
      set("NeoTreeFileIcon", { fg = blue_hour.sky })
      set("NeoTreeIndentMarker", { fg = blue_hour.overlay })
      set("NeoTreeExpander", { fg = blue_hour.muted })
      set("NeoTreeDimText", { fg = blue_hour.overlay })
      set("NeoTreeFadeText1", { fg = blue_hour.overlay })
      set("NeoTreeFadeText2", { fg = blue_hour.overlay })
      set("NeoTreeDotfile", { fg = blue_hour.muted })
      set("NeoTreeHiddenByName", { fg = blue_hour.muted })
      set("NeoTreeWindowsHidden", { fg = blue_hour.muted })
      set("NeoTreeMessage", { fg = blue_hour.muted, italic = true })
      set("NeoTreeFileStats", { fg = blue_hour.muted })
      set("NeoTreeFileStatsHeader", { fg = blue_hour.muted, bold = true, italic = true })
      set("NeoTreeFilterTerm", { fg = blue_hour.sky, bold = true })
      set("NeoTreeTitleBar", { fg = blue_hour.base, bg = blue_hour.sky, bold = true })
      set("NeoTreeTabActive", { fg = blue_hour.text, bold = true })
      set("NeoTreeTabInactive", { fg = blue_hour.muted })
      set("NeoTreeTabSeparatorActive", { fg = blue_hour.overlay })
      set("NeoTreeTabSeparatorInactive", { fg = blue_hour.overlay })

      -- same as the prompt: mint for in, sand for dirty, rose for gone
      set("NeoTreeGitAdded", { fg = blue_hour.mint })
      set("NeoTreeGitStaged", { fg = blue_hour.mint })
      set("NeoTreeGitModified", { fg = blue_hour.sand })
      set("NeoTreeGitUnstaged", { fg = blue_hour.sand })
      set("NeoTreeGitDeleted", { fg = blue_hour.rose })
      set("NeoTreeGitConflict", { fg = blue_hour.rose, bold = true })
      set("NeoTreeGitRenamed", { fg = blue_hour.iris })
      set("NeoTreeGitUntracked", { fg = blue_hour.haze, italic = true })
      set("NeoTreeGitIgnored", { fg = blue_hour.overlay })
      set("NeoTreeIgnored", { fg = blue_hour.overlay })
      set("NeoTreeModified", { fg = blue_hour.sand })

      -- The start screen
      set("DashboardHeader", { fg = blue_hour.sky })
      set("DashboardIcon", { fg = blue_hour.sky })
      set("DashboardDesc", { fg = blue_hour.text })
      set("DashboardKey", { fg = blue_hour.haze })
    end

    -- re-apply on every colorscheme load, so :hi clear does not undo it
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Blue Hour glass overrides",
      callback = blue_hour_overrides,
    })

    blue_hour_overrides()
  '';
}
