{...}: {
  programs.gpg = {
    enable = true;

    publicKeys = [
      {
        source = ./keys/gpg-public.asc;
        trust = "ultimate";
      }
    ];
  };
}
