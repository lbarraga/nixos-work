# NixOS config: structure and conventions

## Goal

A NixOS flake that runs a niri desktop with a quickshell bar. The desktop is packaged so it can be shared and tried by others with `nix run github:<user>/<repo>#niri`, and the same packages are used by my own machines. The config follows the dendritic pattern on top of flake-parts.

## Flake inputs

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  flake-parts.url = "github:hercules-ci/flake-parts";
  import-tree.url = "github:vic/import-tree";
  wrapper-modules = {
    url = "github:nix-community/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # The editor, built from modules/packages/nvim. The one input that does not
  # follow our nixpkgs: nixvim's plugins are built against its own tree, and
  # pointing it at ours tends to break them.
  nixvim.url = "github:nix-community/nixvim";
};

outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
```

Use stable nixpkgs. Do not add new inputs without asking.

## Core philosophy

1. Every `.nix` file under `modules/` is a flake-parts module. `import-tree` loads all of them automatically, so there are no manual `imports` lists for my own files.
2. A `.nix` file that is NOT a flake-parts module (for example a hardware configuration) must have an underscore in its path, such as `_hardware-configuration.nix`, so `import-tree` skips it. The rule is literally that: import-tree drops any path containing `/_`, so an underscore on a *directory* hides the whole subtree. That is how the editor's nixvim modules live under `packages/nvim/_config/` without the outer tree trying to evaluate them as flake-parts modules. The filter runs on the path relative to the directory import-tree was handed, so a second `import-tree ./_config` from inside still sees everything.
3. Do not use `specialArgs` or `extraSpecialArgs`. Shared values go through the flake-parts config or `perSystem` arguments.
4. Keep things simple. No theming system for now.

## Folder structure and rules

```
modules/
  flake/
    flake-parts.nix
  packages/
    foot.nix
    fuzzel.nix
    niri/
      niri.nix
      config.kdl
      bar.nix
      quickshell/
        shell.qml
        Bar.qml
    nvim/
      nvim.nix
      _config/
        core/
        plugins/
        languages/
  features/
    base.nix
    user.nix
    audio.nix
    niri.nix
  hosts/
    vm.nix
    laptop/
      laptop.nix
      _hardware-configuration.nix
```

### `flake/`
Flake setup only. `flake-parts.nix` sets `systems = [ "x86_64-linux" ]` and imports `inputs.flake-parts.flakeModules.modules`, which provides the `flake.modules.<class>.<name>` option.

### `packages/`
Programs wrapped together with my config, usable on any system and any desktop. Files here only define `perSystem.packages`. They never define NixOS modules.

- Wrap programs with `inputs.wrapper-modules.wrappers.<program>.wrap { inherit pkgs; ... }`. `nvim` is the exception: nixvim is its own wrapper and builds the package itself.
- A package is published under `packages` only if it is useful on its own.
- Parts that only make sense inside another package stay private. The quickshell bar only works inside niri (it listens to niri's event stream), so it is wrapped but never published. It is shared with `niri.nix` through `_module.args.niriBar` in `bar.nix`, or written inline. It must never appear under `packages`.
- A package that is private to another package lives in that package's folder.

### `features/`
NixOS modules that hosts pick from, defined as `flake.modules.nixos.<name>`.

- Features are thin. They install packages from `self.packages.${pkgs.stdenv.hostPlatform.system}` and add only what the system itself must provide (services, drivers, session registration, PAM, and so on).
- Each feature brings everything it needs. For example, the niri feature enables `services.upower` because the bar's battery widget reads from it.
- Features know nothing about hosts.

### `hosts/`
One file (or folder) per machine, defining `flake.nixosConfigurations.<name>`.

- A host lists the features it uses, then adds only facts specific to that machine: `nixpkgs.hostPlatform`, `networking.hostName`, `system.stateVersion`, boot loader, hardware file.
- Use `modules = with config.flake.modules.nixos; [ base user audio niri { ... } ];`.
- The VM host also exposes `perSystem.packages.vm = config.flake.nixosConfigurations.vm.config.system.build.vm;` so `nix run .#vm` boots it.

## Config file conventions

- Prefer each program's native config format over Nix translations.
  - niri: a normal `config.kdl`, passed with `"config.kdl".path = ./config.kdl;`.
  - quickshell: normal QML files, passed with `configDir = ./quickshell;`.
  - INI-style programs like foot and fuzzel may use the wrapper's Nix `settings`, since INI maps directly to Nix.
- Programs called by name from a config file (like `spawn "foot"` in niri) are put on the wrapped program's PATH with the wrapper's `runtimePkgs` option. Use `{ data = <pkg>; prefix = true; }` when the wrapped version must win over any system-installed version, as for the quickshell bar.
- Do NOT use `@placeholder@` substitution (`replaceVars`) in config files.
- Do NOT build configs by appending Nix strings to a file read with `builtins.readFile`.
- Do NOT put niri `output` blocks in the config by default. The laptop docks into unknown monitor setups, and niri's automatic placement plus `niri msg output` covers that.

## Colors: the Blue Hour palette

The desktop is themed after the wallpaper, a flat-vector mountain landscape at
`modules/packages/niri/quickshell/wallpaper.jpg`. The structural colors were
sampled from the image itself with imagemagick, then the dark end was extended:
the darkest thing actually in the image is a saturated indigo peak, far too
bright and too chromatic to sit a terminal on, so `base` and `surface` carry
that same hue down into the night behind it until every foreground reaches
WCAG AA on the base.

| Role | Hex | From the wallpaper |
|---|---|---|
| base | `#0A1226` | the night behind the furthest peak -- window and terminal background |
| surface | `#121D36` | the far ridge; bar, panels, pinentry box |
| overlay | `#24406B` | mid-mountain shadow; selections, borders, inactive ring |
| muted | `#7D9CC2` | haze on the ridge line; comments, placeholder, inactive text |
| text | `#E9F4FA` | the sun's disc, cooled; never pure white |
| glow | `#F0DCA0` | the sun's light, warmed: prompt, matches, focus accents |
| sand | `#DCB169` | the same light lower and deeper; warnings, git dirty, selection background |
| rose | `#EC7A8C` | *not in the image*; errors, urgent |
| mint | `#5FC9A4` | *not in the image*; a neighbour of the valley teal; success, git clean |
| sky | `#4FB0F8` | the sky, half the canvas; info, the "blue" slot, niri's focus ring |
| haze | `#7FD8F2` | light at the horizon; the "cyan" slot |
| iris | `#A99BF2` | *not in the image*; a neighbour of the deepest indigo; the magenta slot |

**This wallpaper is a single hue family.** 99.4% of its pixels fall between
hue 190 and 240, and the "sun" is near-white (`#EDFBF1`) rather than warm.
There is no red, yellow, green or magenta anywhere on it to sample. So four
slots had to be invented, and the rule used was: keep the chroma and lightness
of the colors that *are* in the image, and prefer hues that neighbour one
already present. `mint` sits beside the valley teal, `iris` beside the indigo
peaks, and `glow`/`sand` are the sun's light pushed warm -- which is also what
makes them the only warm colors in the scheme, and therefore the accents.
Warm should stay rare here; everything structural is a value of the same blue.

**The hexes are hardcoded in each config, on purpose.** There is no palette
module and no theming system. Two of the consumers (`Bar.qml` and
`pinentry.rasi`) are native config formats, and feeding Nix values into them
would need the substitution this file forbids -- so a shared palette could
never have covered more than half of them anyway. Changing a color means
editing these files:

- `modules/packages/foot.nix` -- `colors` block, 16 ANSI slots
- `modules/packages/fuzzel.nix` -- `colors` block (RRGGBBAA)
- `modules/packages/starship.nix` -- `style` strings
- `modules/features/shell.nix` -- `autosuggestions.highlightStyle`
- `modules/packages/niri/config.kdl` -- `focus-ring` and `border` colors
- `modules/packages/niri/quickshell/Colors.qml` -- **every** color used by the
  QML side: the bar and its widgets, the wallpaper fallback, the notification
  cards. The one place where sharing is possible at all, since it is a single
  language with no Nix substitution involved
- `modules/packages/fastfetch.nix` -- `logo.color` and `display.color`
- `modules/packages/hyprlock.nix` -- `label` and `input-field` colors
- `modules/packages/pinentry/pinentry.rasi` -- the `*` block
- `modules/packages/nvim/_config/plugins/theme.nix` -- the base16 slots, the
  lualine theme table, and the Lua override pass. The other place where
  sharing works: nothing else in the editor names a color

Two of those hide from a naive grep: `fuzzel.nix` writes `RRGGBBAA` and
`hyprlock.nix` writes `rgba(rrggbbaa)`, so a search for six hex digits with
word boundaries misses both. Search for the bare hex without `\b`.

Transparency: foot runs at `alpha=0.82` with `blur=yes`, and the bar at
`#d0121d36`, so the wallpaper shows through both. The blur is real -- niri
advertises `ext_background_effect_manager_v1`, which is the protocol foot's
`blur` option requires.

The editor inherits that glass rather than painting its own. foot applies its
alpha only to cells carrying the *default* background, so any program that
sets an explicit background goes opaque -- which is what a colorscheme
normally does to every cell on screen. Neovim therefore clears the background
on everything that is "the window" and lets the terminal's own background
through. Panels stay solid on `surface`, the same way the bar and the pinentry
box are surface over the blur: a completion menu you can read the wallpaper
through is worse than one you can read.

## The bar

`./quickshell` is one quickshell instance drawing the wallpaper, the bar and
the notifications. The bar is split one file per widget, and since quickshell
auto-registers everything in the config directory, a new widget is a new file
plus one line in `Bar.qml`.

| File | What it is |
|---|---|
| `shell.qml` | the three `Variants`, one per screen |
| `Bar.qml` | layout only: workspaces left, clock centre, status right, plus the hairline that separates other people's tray icons from our own readouts |
| `Colors.qml` | singleton, the palette |
| `Niri.qml` | singleton, workspace state from niri's IPC |
| `Workspaces.qml` | one pill per workspace, click to focus |
| `TrayWidget.qml` | system tray, chevron collapses it horizontally |
| `BluetoothWidget.qml` | adapter state, hidden when the machine has no adapter |
| `NetworkWidget.qml` | wired/wireless icon; wired wins when both are up |
| `BatteryWidget.qml` | level and percentage |
| `Tooltip.qml` | the hover popup the status icons share |

Hovering a status icon opens a `Tooltip`, which is a real `PopupWindow`: the
bar is 30px tall and claims an exclusive zone, so anything drawn inside it
would be clipped. It waits 350ms before appearing, so crossing the icons on
the way elsewhere does not flash three popups.

Clicking opens a manager, named in a `managerCommand` property at the top of
each widget. Bluetooth gets blueman. Wifi gets the fuzzel picker in
`packages/networkmanager-dmenu.nix`, because NetworkManager has no small GTK
window of its own: nm-connection-editor only edits saved connections, and the
only GUI that actually scans is the whole GNOME Settings application. Neither
program is in niri's `runtimePkgs` -- they come from the NixOS side
(`features/network.nix` and `features/bluetooth.nix`), so on another machine
the click is simply a no-op.

Offline is three states, not two. A link can be associated with nothing behind
it, so `NetworkWidget` reads `Networking.connectivity` as well: connected and
`Full` is normal, connected and anything else is `sand` with "no internet" on
the hover label, and no connected device at all strikes the icon through.

Quickshell 0.3 ships modules for Hyprland and i3 but **not** for niri, so
`Niri.qml` runs `niri msg --json event-stream` itself. It only reacts to events
whose name contains `Workspace`: window events fire on every title change,
which inside a terminal means on every keystroke. Rather than replaying events
into a local model it re-reads `niri msg --json workspaces` on a 25ms debounce,
which cannot drift out of sync and costs a few milliseconds.

Things that cost time to find out, all verified against the running session
rather than assumed:

- **Do not name a singleton `Palette`.** QtQuick has a built-in `Palette` value
  type, and it wins the name lookup silently -- every color resolves to
  `undefined`, with a warning that never mentions the collision. Hence
  `Colors.qml`.
- A singleton declaring `property color` must `import QtQuick`. Importing only
  `Quickshell` fails with `color is not a type`.
- `UPowerDevice.percentage` is a **0..1 ratio**, not 0..100.
- `UPower.onBattery` is wrong on this laptop -- it reads `false` while the
  battery is discharging, because the machine exposes three line-power devices.
  Use `displayDevice.state` (1 charging, 2 discharging, 4 full).
- Quickshell services connect lazily and populate asynchronously: a singleton
  read from a one-off `Component.onCompleted` returns empty. Bind to them
  instead, which is also how a widget should use them anyway.
- Inside `Connections`, `parent` is not the enclosing element. Give the
  `Canvas` an id and call `theId.requestPaint()`.

Widget icons are drawn with `Canvas` rather than set as font glyphs, so none of
this depends on which icons the monospace font happens to ship.

## The editor

`packages/nvim` is a nixvim config: one `.nix` file per concern under
`_config`, loaded by a second `import-tree` that the outer one cannot see.
`core/` holds options and global keymaps, `plugins/` one file per plugin,
`languages/` one file per language -- a language file owns everything about
that language at once, the server, the formatter, the treesitter grammar and
the extra packages, so adding a language is adding a file.

nixvim is not a wrapper-modules wrapper, so `nvim.nix` does not take `pkgs`
from `perSystem`. It calls `inputs.nixvim.legacyPackages.${system}` and lets
nixvim build against its own nixpkgs, which is the point of not making that
input follow ours.

The colors live in `_config/plugins/theme.nix` and nowhere else. It is two
layers: base16, which maps the Blue Hour palette onto the sixteen slots every
base16 plugin integration already understands, and a Lua pass that clears the
background on everything structural so the terminal's glass shows through.
The pass runs from a `ColorScheme` autocmd as well as once at startup, so
`:colorscheme` or anything that reloads highlights does not undo it.

**Transparency is not a list of groups, it is one rule**: a group whose
background is the default background should not have a background at all.
base16 paints `base00` onto dozens of groups -- `GitGutterAdd`, every
`GitSigns*`, `DiffAdded`, `DiffFile` -- and each one lands as an opaque block
on the glass. That is what put a box around every changed file in the tree and
every sign in the gutter. So the pass sweeps all of `nvim_get_hl(0, {})` and
drops any background equal to `base00`, rather than naming groups. Naming them
would have been wrong as well as long: nothing in that list is a group I wrote.

The sweep deliberately skips groups that are *links*, and only edits the ones
carrying their own background. A link left intact keeps following its source,
and that is what makes the rule survive lazy plugins: neo-tree defines
`NeoTreeGitAdded -> GitGutterAdd` when the tree first opens, long after the
sweep, and inherits the cleared background for free.

Things that cost time to find out here:

- `vim.api.nvim_set_hl` with no `bg` key means *no background*, which is what
  transparency is. To clear one group's background without throwing away its
  foreground, read it back with `nvim_get_hl(0, { name = g, link = false })`
  first: `link = false` resolves a linked group to real attributes, where the
  default would hand back `{ link = "Normal" }` and setting a `bg` alongside a
  `link` is ignored.
- **A plugin that builds highlights on attach escapes the sweep.** gitsigns'
  `GitSignsStaged*` -- eighteen groups -- are built the first time it attaches
  to a buffer, with the default background baked in, so a startup sweep never
  sees them. Defining them up front is the fix, because gitsigns and neo-tree
  both fill in only the groups a colorscheme left *empty*. That is worth
  knowing in general: setting a plugin's groups before it loads wins, and an
  empty group does not count as set -- clearing the background of a group that
  does not exist yet leaves `{}` behind, which the plugin then overwrites.
- lualine does not read highlight groups, it builds them from a theme table.
  Its section `c` is the fill that spans the window, so that is the one that
  has to be `bg = "NONE"`; the rest of the statusline is panel.
- noice does not route all of its floats through `NormalFloat`, so
  `NoiceCmdlinePopup` and friends need naming separately or the command
  palette comes out transparent while every other float is solid.
- base16's telescope integration gives the prompt, results and preview three
  different backgrounds and inverts all three titles into colored blocks, one
  of which it paints surface-on-surface and so renders invisible. The picker is
  overridden to one `surface` panel, divided by its borders, with the titles as
  colored text; the selected row is then the only thing in it with a background.
  Its `telescope_borders` setting is left off for the same reason -- the borders
  are ours.

## Current state of the key files

`modules/packages/niri/niri.nix`. The bar is wrapped inline here rather than in
its own file: it is private to niri, so it never needs `_module.args` to cross
a file boundary. `configDir` is handed the whole `./quickshell` directory,
wallpaper included, so dropping a new `.qml` or swapping the image needs no
change here.
```nix
{ inputs, ... }: {
  perSystem = { pkgs, config, ... }:
    let
      niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
        inherit pkgs;
        configDir = ./quickshell;
      };
    in {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        "config.kdl".path = ./config.kdl;
        runtimePkgs = [
          config.packages.foot
          config.packages.fuzzel
          pkgs.xwayland-satellite
          pkgs.playerctl
          pkgs.brightnessctl
          pkgs.procps
          config.packages.hyprlock
          { data = niriBar; prefix = true; }
        ];
      };
      packages.default = config.packages.niri;
    };
}
```

`modules/features/niri.nix`:
```nix
{ self, ... }: {
  flake.modules.nixos.niri = { pkgs, ... }:
    let
      mine = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.niri = {
        enable = true;
        package = mine.niri;
      };
      hardware.graphics.enable = true;
      services.upower.enable = true;
      environment.systemPackages = [ mine.foot mine.fuzzel ];
    };
}
```

## Testing workflow

- Flakes only see files tracked by git. Run `git add` on new files before building.
- `nix run .#niri` runs the desktop as a window inside the current session (Mod is Alt there). Use `dbus-run-session nix run .#niri` if apps need to open inside it.
- `nix run .#vm` boots the full system in a VM. This is the honest test of a real login.
- Live editing of the bar: `nix run nixpkgs#quickshell -- -p ./modules/packages/niri/quickshell` (stop the packaged bar first with `pkill quickshell`). Do not use the wrapped quickshell for this, since it already passes a config path.
- Live editing of niri: `nix run nixpkgs#niri -- -c ./modules/packages/niri/config.kdl`.
- Validate niri config: `nix run nixpkgs#niri -- validate -c ./modules/packages/niri/config.kdl`.
- Quickshell panels do not work directly on GNOME (no layer shell). Test the bar inside niri.
- `nix run .#nvim` runs the editor. Run it inside foot, since the colors assume a terminal whose default background is `#0a1226` at `alpha=0.82`.
- The editor's theme is checkable without eyes: `nvim --headless -c 'lua ...' -c 'qa!'` and read groups back with `nvim_get_hl(0, { name = g, link = false })`. A background that comes back `nil` is transparent.

## Things to verify rather than assume

- Option names in nix-wrapper-modules change between versions (for example `runtimePkgs` was previously `extraPackages`). Check the per-module docs at https://nix-community.github.io/nix-wrapper-modules/ before using an option.
- Quickshell API details (property names, services) should be checked against the official quickshell docs for the version in nixpkgs.

## Communication style

Explain things in plain words, in the order: what the situation is, what the problem is, what to do, why. Give full files in code blocks rather than partial snippets when files change.
