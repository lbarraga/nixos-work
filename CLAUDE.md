# NixOS config: structure and conventions

## Goal

A NixOS flake running a niri desktop with a quickshell bar. The desktop is
packaged so others can try it with `nix run github:<user>/<repo>#niri`, and the
same packages are what my own machines install. Dendritic pattern on top of
flake-parts.

## Core philosophy

1. **Every `.nix` file under `modules/` is a flake-parts module.** `import-tree`
   loads all of them, so there are no manual `imports` lists for my own files.
2. **An underscore in the path hides a file from that.** import-tree drops any
   path containing `/_`, so `_hardware-configuration.nix` is skipped and a
   `_config/` *directory* hides a whole subtree — which is how the editor's
   nixvim modules live under `packages/nvim/_config/` without the outer tree
   trying to evaluate them as flake-parts modules. The filter runs on the path
   relative to the directory import-tree was handed, so a second
   `import-tree ./_config` from inside still sees everything.
3. **No `specialArgs` or `extraSpecialArgs`.** Shared values go through the
   flake-parts config or `perSystem` arguments.
4. **Keep it simple.** No theming system, no abstraction before it earns itself.

## Flake inputs

`nixpkgs` (stable, currently `nixos-26.05`), `flake-parts`, `import-tree`,
`wrapper-modules`, `disko`, `nixvim`, `nixpkgs-unstable`.

Use stable nixpkgs. Do not add new inputs without asking.

Two inputs deliberately do not follow our nixpkgs. `nixvim`'s plugins are built
against its own tree and break when pointed at ours. `nixpkgs-unstable` exists
for exactly one package, `brave-origin`, which stable does not carry; it is
referenced directly from `packages/brave`, never as an overlay, so nothing else
is built against it.

## Layout

```
modules/
  flake/flake-parts.nix
  packages/
    foot.nix
    fuzzel.nix
    niri/
      niri.nix
      config.kdl
      quickshell/      # shell.qml, Bar.qml, widgets, wallpaper
    nvim/
      nvim.nix
      _config/         # core/, plugins/, languages/
  features/
    base.nix
    niri.nix
    ...
  hosts/
    claude-vm.nix
    laptop/
      laptop.nix
      _hardware-configuration.nix
      _disko.nix
      format-disks.sh
    desktop/           # same four files
```

### `flake/`
Flake setup only. Sets `systems` and imports
`inputs.flake-parts.flakeModules.modules`, which provides
`flake.modules.<class>.<name>`.

### `packages/`
Programs wrapped with my config, usable on any system and any desktop. These
files define `perSystem.packages` and never NixOS modules.

- Wrap with `inputs.wrapper-modules.wrappers.<program>.wrap { inherit pkgs; … }`.
  `nvim` is the exception: nixvim is its own wrapper.
- A package is published only if it is useful on its own. The quickshell bar
  only works inside niri — it reads niri's event stream — so it is wrapped
  inline in `niri.nix` and never appears under `packages`.
- A package private to another package lives in that package's folder.

### `features/`
NixOS modules hosts pick from, as `flake.modules.nixos.<name>`.

- Thin. They install from `self.packages.${pkgs.stdenv.hostPlatform.system}` and
  add only what the system itself must provide: services, drivers, session
  registration, PAM.
- Each feature brings everything it needs. The niri feature enables
  `services.upower` because the bar's battery widget reads it.
- Features know nothing about hosts.

### `hosts/`
One file or folder per machine, defining `flake.nixosConfigurations.<name>`.

- A host lists its features, then only machine-specific facts: `hostPlatform`,
  `hostName`, `stateVersion`, boot loader, hardware file.
- Real machines own their disk layout too: `_disko.nix` declares the partitions
  and `format-disks.sh` wipes, formats and installs from the ISO. Disko owns
  `fileSystems.*` and `swapDevices`, so `_hardware-configuration.nix` carries
  only the non-filesystem half of `nixos-generate-config`'s output.
- `modules = with config.flake.modules.nixos; [ base user audio niri { … } ];`
- A VM host also exposes `perSystem.packages.<name>` from
  `config.system.build.vm`, so `nix run .#<name>` boots it.

## The two machines

`laptop` and `desktop` share everything structural — niri, the bar, the shell,
the editor, the palette — and differ only in which features they list.

- Laptop only: `power` (TLP), `work-apps` (the two Firefoxes and Mattermost),
  `claude-code`, `docker`.
- Desktop only: `nvidia`, `gaming`, `embedded-dev`, `mouse-config`, `brave`,
  `netbird`, `cad`, `office`, `personal-apps`.
- `common-apps` is what both get, and is the place to put anything that turns
  out to belong on both.

The desktop runs no battery and no bluetooth adapter; the bar needs no
host-awareness for that, since `BatteryWidget` and `BluetoothWidget` already
hide themselves when the hardware is absent.

`config.kdl` lives inside the niri *package*, so both machines share one copy.
That is fine until the desktop wants fixed monitor positions, which the no-
`output`-blocks rule forbids. Unresolved on purpose.

## Config file conventions

- Prefer each program's native config format over a Nix translation. niri gets a
  real `config.kdl` via `"config.kdl".path`; quickshell gets real QML via
  `configDir`. INI-shaped programs like foot and fuzzel may use the wrapper's
  `settings`, since INI maps onto Nix directly.
- Programs called by name from a config (`spawn "foot"`) go on the wrapped
  program's PATH via `runtimePkgs`. Use `{ data = <pkg>; prefix = true; }` when
  the wrapped copy must beat a system-installed one, as the bar does.
- Do NOT use `@placeholder@` substitution (`replaceVars`).
- Do NOT build configs by appending Nix strings to `builtins.readFile`.
- Do NOT add niri `output` blocks by default. The laptop docks into unknown
  monitor setups; niri's automatic placement plus `niri msg output` covers it.

## Colors: the Blue Hour palette

Sampled from the wallpaper at `modules/packages/niri/quickshell/wallpaper.jpg`,
with the dark end extended: the darkest thing in the image is a saturated indigo
peak, too bright to sit a terminal on, so `base` and `surface` carry that hue
down until every foreground clears WCAG AA.

| Role | Hex | Used for |
|---|---|---|
| base | `#0A1226` | window and terminal background |
| surface | `#121D36` | bar, panels, floats, pinentry box |
| overlay | `#24406B` | selections, borders, inactive ring |
| muted | `#7D9CC2` | comments, placeholder, inactive text |
| text | `#E9F4FA` | foreground; never pure white |
| glow | `#F0DCA0` | prompt, matches, focus accents |
| sand | `#DCB169` | warnings, git dirty, selection background |
| rose | `#EC7A8C` | errors, urgent |
| mint | `#5FC9A4` | success, git clean |
| sky | `#4FB0F8` | info, the "blue" slot, niri's focus ring |
| haze | `#7FD8F2` | the "cyan" slot |
| iris | `#A99BF2` | the magenta slot |

The wallpaper is a single hue family — 99.4% of pixels between hue 190 and 240,
with no red, yellow, green or magenta to sample. `rose`, `mint` and `iris` were
invented by keeping the chroma and lightness of colors that *are* present and
picking neighbouring hues. `glow` and `sand` are the sun pushed warm, which
makes them the only warm colors here: warm stays rare, everything structural is
a value of the same blue.

**The hexes are hardcoded in each config, on purpose.** There is no palette
module. Two consumers (`config.kdl`, `pinentry.rasi`) are native formats that
would need the substitution this file forbids, so a shared palette could never
have covered more than half of them. Changing a color means editing:

- `packages/foot.nix` — 16 ANSI slots
- `packages/fuzzel.nix` — `colors` block, RRGGBBAA
- `packages/starship.nix` — `style` strings
- `features/shell.nix` — `autosuggestions.highlightStyle`
- `packages/niri/config.kdl` — `focus-ring` and `border`
- `packages/niri/quickshell/Colors.qml` — every color on the QML side
- `packages/fastfetch.nix` — `logo.color`, `display.color`
- `packages/hyprlock.nix` — `label` and `input-field`
- `packages/pinentry/pinentry.rasi` — the `*` block
- `packages/nvim/_config/plugins/theme.nix` — every color in the editor

`Colors.qml` and `theme.nix` are the two places sharing works at all, each being
one language with no Nix substitution involved.

Two hide from a naive grep: `fuzzel.nix` writes `RRGGBBAA` and `hyprlock.nix`
writes `rgba(rrggbbaa)`. Search for the bare hex without `\b`.

**Glass.** foot runs `alpha=0.82` with `blur=yes` and the bar sits at
`#d0121d36`, so the wallpaper shows through both. The blur is real: niri
advertises `ext_background_effect_manager_v1`, which is what foot's `blur`
requires. foot applies that alpha only to cells carrying the *default*
background, so any program setting an explicit background goes opaque — which is
what a colorscheme normally does to every cell. Hence the editor clears its
backgrounds rather than painting them, and panels stay solid on `surface`.

## The bar

`./quickshell` is one instance drawing the wallpaper, the bar and the
notifications. Quickshell auto-registers everything in the config directory, so
a new widget is a new file plus one line in `Bar.qml`.

| File | What it is |
|---|---|
| `shell.qml` | the `Variants`, one per screen |
| `Wallpaper.qml` | the background layer, below every window |
| `Notifications.qml` | the notification server and its card stack |
| `Bar.qml` | layout only: workspaces left, clock centre, status right |
| `Colors.qml` | singleton, the palette |
| `Niri.qml` | singleton, workspace state from niri's IPC |
| `Workspaces.qml` | one pill per workspace, click to focus |
| `TrayWidget.qml` | system tray, chevron collapses it |
| `BluetoothWidget.qml` | adapter state, hidden with no adapter |
| `NetworkWidget.qml` | wired/wireless; wired wins when both are up |
| `BatteryWidget.qml` | level and percentage |
| `Tooltip.qml` | the hover popup the status icons share |

A `Tooltip` is a real `PopupWindow`: the bar is 30px with an exclusive zone, so
anything drawn inside it would be clipped. It waits 350ms, so crossing the icons
does not flash three popups.

Clicking a status icon opens a manager, named in `managerCommand` at the top of
the widget — blueman for bluetooth, the fuzzel picker in
`packages/networkmanager-dmenu.nix` for wifi. Neither is in niri's
`runtimePkgs`; they come from `features/`, so on another machine the click is a
no-op.

Offline is three states. A link can be associated with nothing behind it, so
`NetworkWidget` reads `Networking.connectivity` too: `Full` is normal, anything
else is `sand` with "no internet" on the label, and no device at all strikes the
icon through.

Quickshell 0.3 has modules for Hyprland and i3 but **not** niri, so `Niri.qml`
runs `niri msg --json event-stream` itself. It reacts only to events whose name
contains `Workspace` — window events fire on every title change, which in a
terminal means every keystroke — and re-reads `niri msg --json workspaces` on a
25ms debounce rather than replaying events into a local model.

Widget icons are drawn with `Canvas`, not font glyphs, so nothing depends on
which runes the monospace font ships.

Things that cost time to find out:

- **Do not name a singleton `Palette`.** QtQuick has a built-in `Palette` value
  type that wins the lookup silently; every color resolves to `undefined`, with
  a warning that never mentions the collision. Hence `Colors.qml`.
- A singleton declaring `property color` must `import QtQuick`. Importing only
  `Quickshell` fails with `color is not a type`.
- `UPowerDevice.percentage` is a **0..1 ratio**, not 0..100.
- `UPower.onBattery` is wrong on this laptop — it reads `false` while the
  battery discharges, because the machine exposes three line-power devices. Use
  `displayDevice.state` (1 charging, 2 discharging, 4 full).
- Quickshell services connect lazily and populate asynchronously. A singleton
  read from a one-off `Component.onCompleted` returns empty; bind to it instead.
- Inside `Connections`, `parent` is not the enclosing element. Give the `Canvas`
  an id and call `theId.requestPaint()`.

## The editor

`packages/nvim` is a nixvim config, one file per concern under `_config`, loaded
by a second `import-tree` the outer one cannot see. `core/` holds options and
keymaps, `plugins/` one file per plugin, `languages/` one file per language — a
language file owns the server, the formatter, the grammar and the extra packages
at once, so adding a language is adding a file.

`nvim.nix` does not take `pkgs` from `perSystem`: it calls
`inputs.nixvim.legacyPackages.${system}` and lets nixvim build against its own
nixpkgs, which is the point of not making that input follow ours.

Colors live in `_config/plugins/theme.nix` and nowhere else: base16 for the
sixteen slots every plugin integration understands, then a Lua pass for the
glass. The pass runs from a `ColorScheme` autocmd as well as at startup, so
`:colorscheme` does not undo it.

**Transparency is one rule, not a list of groups**: a group whose background is
the default background should not have a background at all. base16 paints
`base00` onto dozens of groups — `GitGutterAdd`, every `GitSigns*`, `DiffAdded`
— and each lands as an opaque block on the glass. So the pass sweeps
`nvim_get_hl(0, {})` and drops any background equal to `base00`. It skips
*links*, editing only groups that carry their own background, which is what
makes the rule survive lazy plugins: neo-tree links `NeoTreeGitAdded` to
`GitGutterAdd` when the tree first opens and inherits the fix.

Things that cost time to find out:

- `nvim_set_hl` with no `bg` key means *no background*. To clear one without
  losing its foreground, read it back with
  `nvim_get_hl(0, { name = g, link = false })` first — `link = false` resolves a
  linked group to real attributes, where the default hands back
  `{ link = "Normal" }` and a `bg` set alongside a `link` is ignored.
- **A plugin that builds highlights on attach escapes the sweep.** gitsigns'
  eighteen `GitSignsStaged*` groups are built on first attach with the default
  background baked in. Defining them up front is the fix: gitsigns and neo-tree
  both fill in only groups a colorscheme left *empty* — and an empty group does
  not count as set, so clearing the background of a group that does not exist
  yet leaves `{}` behind for the plugin to overwrite.
- lualine builds its groups from a theme table rather than reading highlights.
  Section `c` is the fill spanning the window, so that is the `bg = "NONE"` one.
- noice does not route all its floats through `NormalFloat`, so
  `NoiceCmdlinePopup` and friends need naming separately.
- base16's telescope integration gives prompt, results and preview three
  different backgrounds and inverts the titles into blocks, one of them
  surface-on-surface and so invisible. Overridden to one `surface` panel divided
  by its borders, with only the selected row taking a background.

## Testing

- Flakes only see files tracked by git. `git add` new files before building.
- `nix run .#niri` runs the desktop windowed inside the current session (Mod is
  Alt there). `dbus-run-session nix run .#niri` if apps need to open inside it.
- `nix run .#claude-vm` boots the full system in a VM — the honest test of a
  real login.
- Installing a real machine: boot the ISO, clone this flake, run
  `modules/hosts/<name>/format-disks.sh`. It wipes the disk, so it asks first.
- `nix run .#nvim` runs the editor. Run it inside foot: the colors assume a
  terminal whose default background is `#0a1226` at `alpha=0.82`.
- Live-edit the bar with
  `nix run nixpkgs#quickshell -- -p ./modules/packages/niri/quickshell` after
  `pkill quickshell`. Not the wrapped one, which already passes a config path.
- Live-edit niri with `nix run nixpkgs#niri -- -c ./modules/packages/niri/config.kdl`,
  and check it with `niri validate -c …`.
- Quickshell panels need layer shell, so they do not work on GNOME. Test the bar
  inside niri.
- The editor's theme is checkable without eyes: read groups back in a headless
  nvim with `nvim_get_hl(0, { name = g, link = false })`. A background that comes
  back `nil` is transparent.

## Verify rather than assume

- nix-wrapper-modules renames options between versions (`runtimePkgs` was
  `extraPackages`). Check https://nix-community.github.io/nix-wrapper-modules/.
- Check quickshell property and service names against the docs for the version
  in nixpkgs.

## Communication style

Plain words, in the order: situation, problem, what to do, why. Full files in
code blocks rather than partial snippets when files change. No comments that
restate what the code already says.
