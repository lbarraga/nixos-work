{inputs, ...}: {
  perSystem = {system, ...}: {
    # No `pkgs`: nixvim builds against its own nixpkgs, which its plugins are
    # pinned to.
    #
    # The underscore on ./_config keeps the outer `import-tree ./modules` out
    # of it -- those are nixvim modules, not flake-parts ones. The inner
    # import-tree filters relative to ./_config, so it still sees them all.
    packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
      module.imports = [(inputs.import-tree ./_config)];
    };
  };
}
