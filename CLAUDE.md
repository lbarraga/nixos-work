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
};

outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
```

Use stable nixpkgs. Do not add new inputs without asking.

## Core philosophy

1. Every `.nix` file under `modules/` is a flake-parts module. `import-tree` loads all of them automatically, so there are no manual `imports` lists for my own files.
2. A `.nix` file that is NOT a flake-parts module (for example a hardware configuration) must have an underscore in its path, such as `_hardware-configuration.nix`, so `import-tree` skips it.
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

- Wrap programs with `inputs.wrapper-modules.wrappers.<program>.wrap { inherit pkgs; ... }`.
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

## Colors: the Ninth Wave palette

The desktop is themed after the wallpaper, Aivazovsky's *The Ninth Wave*. The
colors below were sampled from the painting itself with imagemagick, then the
darkest and lightest were nudged until every foreground reaches WCAG AA on the
base.

| Role | Hex | From the painting |
|---|---|---|
| base | `#14160E` | deepest shadow -- window and terminal background |
| surface | `#232518` | bar, panels, pinentry box |
| overlay | `#3F402B` | selections, borders, inactive ring |
| muted | `#9A8265` | comments, placeholder, inactive text |
| text | `#EFE3C4` | warm parchment, never pure white |
| sun | `#F5D62E` | primary accent: prompt, focus ring, matches |
| amber | `#DE982D` | warnings, git dirty, selection background |
| fire | `#E8703A` | errors, urgent |
| rust | `#C96A4A` | secondary red; also stands in for magenta |
| crest | `#9DBF4E` | success, git clean |
| sea | `#7FB0B3` | the only cool tone in the painting; info, the "blue" slot |

The painting has no purple, so the magenta slot reuses `rust` rather than
inventing a hue that is not on the canvas.

**The hexes are hardcoded in each config, on purpose.** There is no palette
module and no theming system. Two of the consumers (`Bar.qml` and
`pinentry.rasi`) are native config formats, and feeding Nix values into them
would need the substitution this file forbids -- so a shared palette could
never have covered more than half of them anyway. Changing a color means
editing these files:

- `modules/packages/foot.nix` -- `colors` block, 16 ANSI slots
- `modules/packages/fuzzel.nix` -- `colors` block (RRGGBBAA)
- `modules/packages/starship.nix` -- `style` strings
- `modules/packages/niri/config.kdl` -- `focus-ring` and `border` colors
- `modules/packages/niri/quickshell/Bar.qml` -- bar background and text
- `modules/packages/niri/quickshell/Wallpaper.qml` -- pre-load fallback
- `modules/packages/fastfetch.nix` -- `logo.color` and `display.color`
- `modules/features/yubikey/pinentry.rasi` -- the `*` block

Transparency: foot runs at `alpha=0.82` with `blur=yes`, and the bar at
`#d0232518`, so the wallpaper shows through both. The blur is real -- niri
advertises `ext_background_effect_manager_v1`, which is the protocol foot's
`blur` option requires.

## Current state of the key files

`modules/packages/niri/niri.nix`:
```nix
{ inputs, ... }: {
  perSystem = { pkgs, config, niriBar, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      "config.kdl".path = ./config.kdl;
      runtimePkgs = [
        config.packages.foot
        config.packages.fuzzel
        pkgs.xwayland-satellite
        { data = niriBar; prefix = true; }
      ];
    };
    packages.default = config.packages.niri;
  };
}
```

`modules/packages/niri/bar.nix`:
```nix
{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    _module.args.niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
      inherit pkgs;
      configDir = ./quickshell;
    };
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

## Things to verify rather than assume

- Option names in nix-wrapper-modules change between versions (for example `runtimePkgs` was previously `extraPackages`). Check the per-module docs at https://nix-community.github.io/nix-wrapper-modules/ before using an option.
- Quickshell API details (property names, services) should be checked against the official quickshell docs for the version in nixpkgs.

## Communication style

Explain things in plain words, in the order: what the situation is, what the problem is, what to do, why. Give full files in code blocks rather than partial snippets when files change.
