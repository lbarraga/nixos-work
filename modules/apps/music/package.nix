{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.rmpc =
      let
        # rmpc recursively inotify-watches the config file's *parent
        # directory*, and does it with `enable_config_hot_reload` off too:
        # main.rs writes `flag.then_some(config_watcher::init(…))`, whose
        # argument is evaluated either way. A config file sitting bare in
        # /nix/store makes that watch the entire store. Its own directory
        # makes it two files.
        configDir = pkgs.linkFarm "rmpc-config" {
          "config.ron" = ./config.ron;
          "theme.ron" = ./theme.ron;
        };
      in
      inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.rmpc;
        flags = {
          "--config" = "${configDir}/config.ron";
          "--theme" = "${configDir}/theme.ron";
        };
      };
  };
}
