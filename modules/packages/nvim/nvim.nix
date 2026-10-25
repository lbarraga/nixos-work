{inputs, ...}: {
  perSystem = {system, ...}: {
    packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
      module.imports = [(inputs.import-tree ./_config)];
    };
  };
}
