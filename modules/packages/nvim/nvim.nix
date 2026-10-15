{inputs, ...}: {
  perSystem = {system, ...}: {
    # nixvim builds against its own nixpkgs on purpose. Its plugins are pinned
    # to that tree, and making it follow ours tends to break them, so `pkgs`
    # is deliberately not passed in here.
    #
    # The editor's own config lives in ./_config. The underscore keeps the
    # outer `import-tree ./modules` out of it: those files are nixvim modules,
    # not flake-parts modules, and would fail to evaluate as the latter. The
    # inner import-tree below filters paths relative to ./_config, so it still
    # sees all of them.
    packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
      module.imports = [(inputs.import-tree ./_config)];
    };
  };
}
