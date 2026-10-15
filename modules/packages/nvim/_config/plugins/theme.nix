# The Blue Hour palette -- see CLAUDE.md. This is the only file in the editor
# that names a color, including lualine's, so changing the scheme means
# changing this file and nothing else.
#
# Two layers:
#
#   1. base16, which maps the palette onto the sixteen slots every base16
#      plugin integration already understands (treesitter, telescope, cmp,
#      gitsigns, notify, indent-blankline).
#   2. a Lua pass that makes the editor glass. foot runs at alpha=0.82 with
#      blur, but it only applies that alpha to cells carrying the *default*
#      background, so anything with an explicit background is opaque.
#
# What floats stays solid, on `surface`. That is the same rule the desktop
# already follows: the bar and the pinentry box are surface over the blur,
# and a completion menu you cannot read through is worth more than one more
# transparent rectangle.
{
  colorschemes.base16 = {
    enable = true;

    # base04 repeats `muted` and base06/07 repeat `text`: the palette has one
    # step between comment and foreground, not three. base0F has no hue of its
    # own in the scheme either, so it borrows `sand`.
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

  # lualine reads its colors from a theme table rather than from highlight
  # groups, so the glass pass below cannot reach it. Section c is the fill that
  # spans the window, and it is the part that has to be NONE.
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
      bg = "#f0dca0";
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

    -- nvim hands backgrounds back as numbers, so `base` is needed in that form
    -- to recognise it.
    local BASE = tonumber("0a1226", 16)

    local function set(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end

    -- A group whose background is the default background is a group that
    -- should not have a background at all. foot gives its alpha only to
    -- default-bg cells, so an explicit #0a1226 comes out as an opaque block
    -- sitting on the glass -- which is what the git markers in the file tree
    -- and the signs in the gutter were. base16 paints base00 onto dozens of
    -- groups, so this is a sweep rather than a list.
    --
    -- Only groups that carry their own background are touched. A linked group
    -- is left linked, so it goes on following its source, and that is what
    -- makes this hold for plugins that create their links long after startup:
    -- neo-tree first defines NeoTreeGitAdded -> GitGutterAdd when the tree
    -- opens, and inherits the cleared background for free.
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
      set("CursorLineNr", { fg = blue_hour.glow, bold = true })
      set("EndOfBuffer", { fg = blue_hour.overlay })
      set("WinSeparator", { fg = blue_hour.overlay })
      set("VertSplit", { fg = blue_hour.overlay })
      set("Visual", { bg = blue_hour.overlay })
      set("Search", { fg = blue_hour.base, bg = blue_hour.glow })
      set("IncSearch", { fg = blue_hour.base, bg = blue_hour.sand })
      set("CurSearch", { fg = blue_hour.base, bg = blue_hour.sand })
      set("MatchParen", { fg = blue_hour.glow, bold = true, underline = true })
      set("LspInlayHint", { fg = blue_hour.muted, italic = true })

      -- Indent guides: the passive ones barely there, the active scope one
      -- step up so it reads without competing with the code.
      set("IblIndent", { fg = blue_hour.overlay })
      set("IblScope", { fg = blue_hour.muted })
      set("MiniIndentscopeSymbol", { fg = blue_hour.muted })

      -- What floats: solid surface, overlay border, warm title.
      set("NormalFloat", { fg = blue_hour.text, bg = blue_hour.surface })
      set("FloatBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("FloatTitle", { fg = blue_hour.glow, bg = blue_hour.surface, bold = true })
      set("Pmenu", { fg = blue_hour.text, bg = blue_hour.surface })
      set("PmenuSel", { fg = blue_hour.text, bg = blue_hour.overlay, bold = true })
      set("PmenuSbar", { bg = blue_hour.surface })
      set("PmenuThumb", { bg = blue_hour.overlay })
      set("NotifyBackground", { bg = blue_hour.surface })

      -- noice draws its own floats and does not route them all through
      -- NormalFloat, so the cmdline and the message popups are named here too.
      set("NoiceCmdlinePopup", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoiceCmdlinePopupBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("NoiceCmdlinePopupTitle", { fg = blue_hour.glow, bg = blue_hour.surface, bold = true })
      set("NoiceCmdlineIcon", { fg = blue_hour.glow })
      set("NoiceCmdlinePrompt", { fg = blue_hour.glow })
      set("NoicePopup", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoicePopupBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })
      set("NoiceConfirm", { fg = blue_hour.text, bg = blue_hour.surface })
      set("NoiceConfirmBorder", { fg = blue_hour.overlay, bg = blue_hour.surface })

      -- Telescope is one panel, not four.
      --
      -- base16's own integration gives each of the three windows a different
      -- background and then inverts all three titles into colored blocks, so
      -- the picker arrives as a stack of slabs with the results title painted
      -- surface-on-surface and therefore invisible. Here every window is the
      -- same `surface`, the borders draw the divisions, and the titles are
      -- colored text rather than colored boxes. Only the selected row takes a
      -- background, which is then the one thing on screen that has one.
      local panel = { fg = blue_hour.text, bg = blue_hour.surface }
      local border = { fg = blue_hour.overlay, bg = blue_hour.surface }

      set("TelescopeNormal", panel)
      set("TelescopeBorder", border)
      set("TelescopeTitle", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopePromptNormal", panel)
      set("TelescopePromptBorder", border)
      set("TelescopePromptTitle", { fg = blue_hour.glow, bg = blue_hour.surface, bold = true })
      set("TelescopePromptPrefix", { fg = blue_hour.glow, bg = blue_hour.surface })
      set("TelescopePromptCounter", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopeResultsNormal", panel)
      set("TelescopeResultsBorder", border)
      set("TelescopeResultsTitle", { fg = blue_hour.muted, bg = blue_hour.surface })

      set("TelescopePreviewNormal", panel)
      set("TelescopePreviewBorder", border)
      set("TelescopePreviewTitle", { fg = blue_hour.sky, bg = blue_hour.surface, bold = true })
      set("TelescopePreviewLine", { bg = blue_hour.overlay })
      set("TelescopePreviewMatch", { fg = blue_hour.base, bg = blue_hour.glow })

      set("TelescopeSelection", { fg = blue_hour.text, bg = blue_hour.overlay, bold = true })
      set("TelescopeSelectionCaret", { fg = blue_hour.glow, bg = blue_hour.overlay })
      set("TelescopeMultiSelection", { fg = blue_hour.iris })
      set("TelescopeMultiIcon", { fg = blue_hour.iris })
      set("TelescopeMatching", { fg = blue_hour.glow, bold = true })

      -- git_status rows otherwise inherit DiffAdd and friends, whose
      -- backgrounds base16 blends for whole diff lines and which stripe the
      -- result list.
      set("TelescopeResultsDiffAdd", { fg = blue_hour.mint })
      set("TelescopeResultsDiffChange", { fg = blue_hour.sand })
      set("TelescopeResultsDiffDelete", { fg = blue_hour.rose })
      set("TelescopeResultsDiffUntracked", { fg = blue_hour.muted })

      -- gitsigns builds its staged groups lazily, on first attach, with the
      -- default background baked in -- after the sweep above has already run,
      -- so they are the one thing it cannot catch. Defining them up front is
      -- what catches them: gitsigns, like neo-tree, fills in only the groups a
      -- colorscheme left empty.
      --
      -- Unstaged carries the accent, staged goes `muted`: the sign character
      -- already says which kind of change it is, and the color is then free to
      -- say the part the character cannot, which is whether it still needs
      -- doing.
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

      -- neo-tree hardcodes a set of greys and an orange that belong to no
      -- scheme at all, and it keeps them whenever a colorscheme does not name
      -- the group. It only fills in groups that are still empty, so defining
      -- them here wins even though the tree loads later.
      set("NeoTreeNormal", { fg = blue_hour.text })
      set("NeoTreeNormalNC", { fg = blue_hour.text })
      set("NeoTreeEndOfBuffer", { fg = blue_hour.overlay })
      set("NeoTreeWinSeparator", { fg = blue_hour.overlay })
      set("NeoTreeVertSplit", { fg = blue_hour.overlay })
      set("NeoTreeRootName", { fg = blue_hour.glow, bold = true })
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
      set("NeoTreeFilterTerm", { fg = blue_hour.glow, bold = true })
      set("NeoTreeTitleBar", { fg = blue_hour.base, bg = blue_hour.glow, bold = true })
      set("NeoTreeTabActive", { fg = blue_hour.text, bold = true })
      set("NeoTreeTabInactive", { fg = blue_hour.muted })
      set("NeoTreeTabSeparatorActive", { fg = blue_hour.overlay })
      set("NeoTreeTabSeparatorInactive", { fg = blue_hour.overlay })

      -- Git state in the tree reads the same as git state in the prompt:
      -- mint for what is in, sand for what is dirty, rose for what is gone.
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
      set("DashboardIcon", { fg = blue_hour.glow })
      set("DashboardDesc", { fg = blue_hour.text })
      set("DashboardKey", { fg = blue_hour.sand })
    end

    -- Re-apply on every colorscheme load, so :colorscheme and anything that
    -- reloads highlights (a live-reloaded plugin, :hi clear) does not undo it.
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Blue Hour glass overrides",
      callback = blue_hour_overrides,
    })

    blue_hour_overrides()
  '';
}
