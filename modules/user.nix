{pkgs, ...}: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.lukasbt = {
    isNormalUser = true;
    description = "Lukas Barragan Torres";
    extraGroups = ["networkmanager" "wheel" "lp"];
  };
}
