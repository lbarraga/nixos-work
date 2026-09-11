{...}: {
  programs.git = {
    enable = true;

    signing = {
      format = "openpgp";

      key = "7D7927AE9E9E61C7736EE6A8D78940BF1814BF2E";

      # Sign every commit and tag without needing `-S`.
      signByDefault = true;
    };

    settings = {
      user = {
        email = "lukas.barragantorres@ugent.be";
        name = "Lukas Barragan Torres";
      };
      alias.ac = "!git add . && git commit -m";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
