# Hillside palette -- see CLAUDE.md. The only file in the editor that names a
# color. base16 for the sixteen slots every plugin integration understands,
# then a Lua pass for the glass. Floats stay solid on `surface`, like the bar.
{
  colorschemes.base16 = {
    enable = true;

    # base04/06/07 repeat: the palette has one step between comment and
    # foreground, not three. base0F has no hue of its own, so it borrows wheat.
    colorscheme = {
      base00 = "#09180d"; # base    -- background
      base01 = "#102416"; # surface -- cursor line, panels
      base02 = "#274a31"; # overlay -- selection
      base03 = "#80a48e"; # muted   -- comments
      base04 = "#80a48e"; # muted
      base05 = "#ecf5ed"; # text    -- foreground
      base06 = "#ecf5ed"; # text
      base07 = "#ecf5ed"; # text
      base08 = "#ee7d76"; # ember   -- variables, errors
      base09 = "#d9b361"; # wheat   -- numbers, constants
      base0A = "#eddda0"; # sun     -- types, search
      base0B = "#94c976"; # fern    -- strings, added
      base0C = "#83d7f2"; # sky     -- escapes, support
      base0D = "#1fbfbf"; # aqua    -- functions
      base0E = "#cb90d8"; # bloom   -- keywords
      base0F = "#d9b361"; # wheat   -- specials
    };
  };

  # lualine builds its groups from a theme table, so the glass pass cannot
  # reach it. Section c is the fill that spans the window, hence bg = NONE.
  plugins.lualine.settings.options.theme = {
    normal = {
      a = {
        fg = "#09180d";
        bg = "#1fbfbf";
        gui = "bold";
      };
      b = {
        fg = "#ecf5ed";
        bg = "#102416";
      };
      c = {
        fg = "#80a48e";
        bg = "NONE";
      };
    };
    insert.a = {
      fg = "#09180d";
      bg = "#94c976";
      gui = "bold";
    };
    visual.a = {
      fg = "#09180d";
      bg = "#cb90d8";
      gui = "bold";
    };
    replace.a = {
      fg = "#09180d";
      bg = "#ee7d76";
      gui = "bold";
    };
    command.a = {
      fg = "#09180d";
      bg = "#83d7f2";
      gui = "bold";
    };
    inactive = {
      a = {
        fg = "#80a48e";
        bg = "NONE";
      };
      b = {
        fg = "#80a48e";
        bg = "NONE";
      };
      c = {
        fg = "#80a48e";
        bg = "NONE";
      };
    };
  };

  extraConfigLua = ''
    local hillside = {
      base = "#09180d",
      surface = "#102416",
      overlay = "#274a31",
      muted = "#80a48e",
      text = "#ecf5ed",
      sun = "#eddda0",
      wheat = "#d9b361",
      ember = "#ee7d76",
      fern = "#94c976",
      aqua = "#1fbfbf",
      sky = "#83d7f2",
      bloom = "#cb90d8",
    }

    -- nvim hands backgrounds back as numbers.
    local BASE = tonumber("09180d", 16)

    local function set(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end

    -- foot only alpha-blends cells carrying the default background, so an
    -- explicit #09180d is an opaque block on the glass. base16 paints base00
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

    local function hillside_overrides()
      unbackground_default()

      -- The window
      set("LineNr", { fg = hillside.overlay })
      set("CursorLineNr", { fg = hillside.aqua, bold = true })
      set("EndOfBuffer", { fg = hillside.overlay })
      set("WinSeparator", { fg = hillside.overlay })
      set("VertSplit", { fg = hillside.overlay })
      set("Visual", { bg = hillside.overlay })
      set("Search", { fg = hillside.base, bg = hillside.aqua })
      set("IncSearch", { fg = hillside.base, bg = hillside.sky })
      set("CurSearch", { fg = hillside.base, bg = hillside.sky })
      set("MatchParen", { fg = hillside.aqua, bold = true, underline = true })
      set("LspInlayHint", { fg = hillside.muted, italic = true })

      -- active scope one step brighter than the passive guides
      set("IblIndent", { fg = hillside.overlay })
      set("IblScope", { fg = hillside.muted })
      set("MiniIndentscopeSymbol", { fg = hillside.muted })

      -- floats: solid surface, overlay border, warm title
      set("NormalFloat", { fg = hillside.text, bg = hillside.surface })
      set("FloatBorder", { fg = hillside.overlay, bg = hillside.surface })
      set("FloatTitle", { fg = hillside.aqua, bg = hillside.surface, bold = true })
      set("Pmenu", { fg = hillside.text, bg = hillside.surface })
      set("PmenuSel", { fg = hillside.text, bg = hillside.overlay, bold = true })
      set("PmenuSbar", { bg = hillside.surface })
      set("PmenuThumb", { bg = hillside.overlay })
      set("NotifyBackground", { bg = hillside.surface })

      -- noice does not route all its floats through NormalFloat.
      set("NoiceCmdlinePopup", { fg = hillside.text, bg = hillside.surface })
      set("NoiceCmdlinePopupBorder", { fg = hillside.overlay, bg = hillside.surface })
      set("NoiceCmdlinePopupTitle", { fg = hillside.aqua, bg = hillside.surface, bold = true })
      set("NoiceCmdlineIcon", { fg = hillside.aqua })
      set("NoiceCmdlinePrompt", { fg = hillside.aqua })
      set("NoicePopup", { fg = hillside.text, bg = hillside.surface })
      set("NoicePopupBorder", { fg = hillside.overlay, bg = hillside.surface })
      set("NoiceConfirm", { fg = hillside.text, bg = hillside.surface })
      set("NoiceConfirmBorder", { fg = hillside.overlay, bg = hillside.surface })

      -- One panel, not four. base16's integration gives the three windows
      -- different backgrounds and inverts the titles into blocks, one of them
      -- surface-on-surface and so invisible. Here the borders do the dividing
      -- and only the selected row gets a background.
      local panel = { fg = hillside.text, bg = hillside.surface }
      local border = { fg = hillside.overlay, bg = hillside.surface }

      set("TelescopeNormal", panel)
      set("TelescopeBorder", border)
      set("TelescopeTitle", { fg = hillside.muted, bg = hillside.surface })

      set("TelescopePromptNormal", panel)
      set("TelescopePromptBorder", border)
      set("TelescopePromptTitle", { fg = hillside.aqua, bg = hillside.surface, bold = true })
      set("TelescopePromptPrefix", { fg = hillside.aqua, bg = hillside.surface })
      set("TelescopePromptCounter", { fg = hillside.muted, bg = hillside.surface })

      set("TelescopeResultsNormal", panel)
      set("TelescopeResultsBorder", border)
      set("TelescopeResultsTitle", { fg = hillside.muted, bg = hillside.surface })

      set("TelescopePreviewNormal", panel)
      set("TelescopePreviewBorder", border)
      set("TelescopePreviewTitle", { fg = hillside.aqua, bg = hillside.surface, bold = true })
      set("TelescopePreviewLine", { bg = hillside.overlay })
      set("TelescopePreviewMatch", { fg = hillside.base, bg = hillside.aqua })

      set("TelescopeSelection", { fg = hillside.text, bg = hillside.overlay, bold = true })
      set("TelescopeSelectionCaret", { fg = hillside.aqua, bg = hillside.overlay })
      set("TelescopeMultiSelection", { fg = hillside.bloom })
      set("TelescopeMultiIcon", { fg = hillside.bloom })
      set("TelescopeMatching", { fg = hillside.aqua, bold = true })

      -- otherwise these inherit DiffAdd's line-blend bg and stripe the list
      set("TelescopeResultsDiffAdd", { fg = hillside.fern })
      set("TelescopeResultsDiffChange", { fg = hillside.wheat })
      set("TelescopeResultsDiffDelete", { fg = hillside.ember })
      set("TelescopeResultsDiffUntracked", { fg = hillside.muted })

      -- gitsigns builds its staged groups on first attach, after the sweep
      -- has run, so the sweep cannot catch them. Defining them up front does:
      -- gitsigns, like neo-tree, only fills in groups left empty.
      --
      -- Staged goes muted; the sign character already says which kind it is.
      local git_signs = {
        Add = hillside.fern,
        Change = hillside.wheat,
        Changedelete = hillside.wheat,
        Delete = hillside.ember,
        Topdelete = hillside.ember,
        Untracked = hillside.sky,
      }
      for kind, color in pairs(git_signs) do
        for _, suffix in ipairs({ "", "Cul", "Nr" }) do
          set("GitSigns" .. kind .. suffix, { fg = color })
          set("GitSignsStaged" .. kind .. suffix, { fg = hillside.muted })
        end
      end

      -- neo-tree hardcodes off-palette greys and an orange for any group a
      -- colorscheme leaves empty, so these win even though it loads later.
      set("NeoTreeNormal", { fg = hillside.text })
      set("NeoTreeNormalNC", { fg = hillside.text })
      set("NeoTreeEndOfBuffer", { fg = hillside.overlay })
      set("NeoTreeWinSeparator", { fg = hillside.overlay })
      set("NeoTreeVertSplit", { fg = hillside.overlay })
      set("NeoTreeRootName", { fg = hillside.aqua, bold = true })
      set("NeoTreeFileName", { fg = hillside.text })
      set("NeoTreeFileNameOpened", { fg = hillside.text, bold = true })
      set("NeoTreeDirectoryName", { fg = hillside.aqua })
      set("NeoTreeDirectoryIcon", { fg = hillside.aqua })
      set("NeoTreeFileIcon", { fg = hillside.aqua })
      set("NeoTreeIndentMarker", { fg = hillside.overlay })
      set("NeoTreeExpander", { fg = hillside.muted })
      set("NeoTreeDimText", { fg = hillside.overlay })
      set("NeoTreeFadeText1", { fg = hillside.overlay })
      set("NeoTreeFadeText2", { fg = hillside.overlay })
      set("NeoTreeDotfile", { fg = hillside.muted })
      set("NeoTreeHiddenByName", { fg = hillside.muted })
      set("NeoTreeWindowsHidden", { fg = hillside.muted })
      set("NeoTreeMessage", { fg = hillside.muted, italic = true })
      set("NeoTreeFileStats", { fg = hillside.muted })
      set("NeoTreeFileStatsHeader", { fg = hillside.muted, bold = true, italic = true })
      set("NeoTreeFilterTerm", { fg = hillside.aqua, bold = true })
      set("NeoTreeTitleBar", { fg = hillside.base, bg = hillside.aqua, bold = true })
      set("NeoTreeTabActive", { fg = hillside.text, bold = true })
      set("NeoTreeTabInactive", { fg = hillside.muted })
      set("NeoTreeTabSeparatorActive", { fg = hillside.overlay })
      set("NeoTreeTabSeparatorInactive", { fg = hillside.overlay })

      -- same as the prompt: mint for in, sand for dirty, rose for gone
      set("NeoTreeGitAdded", { fg = hillside.fern })
      set("NeoTreeGitStaged", { fg = hillside.fern })
      set("NeoTreeGitModified", { fg = hillside.wheat })
      set("NeoTreeGitUnstaged", { fg = hillside.wheat })
      set("NeoTreeGitDeleted", { fg = hillside.ember })
      set("NeoTreeGitConflict", { fg = hillside.ember, bold = true })
      set("NeoTreeGitRenamed", { fg = hillside.bloom })
      set("NeoTreeGitUntracked", { fg = hillside.sky, italic = true })
      set("NeoTreeGitIgnored", { fg = hillside.overlay })
      set("NeoTreeIgnored", { fg = hillside.overlay })
      set("NeoTreeModified", { fg = hillside.wheat })

      -- The start screen
      set("DashboardHeader", { fg = hillside.aqua })
      set("DashboardIcon", { fg = hillside.aqua })
      set("DashboardDesc", { fg = hillside.text })
      set("DashboardKey", { fg = hillside.sky })
    end

    -- re-apply on every colorscheme load, so :hi clear does not undo it
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Hillside glass overrides",
      callback = hillside_overrides,
    })

    hillside_overrides()
  '';
}
