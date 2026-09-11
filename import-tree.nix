# Minimal reimplementation of github:vic/import-tree, covering just the
# `import-tree ./dir` usage: recursively imports every *.nix file under a
# directory, skipping paths with a hidden (`_`-prefixed) segment.
dir:
let
  isHidden = path: builtins.match ".*/_[^/]*(/.*)?" (toString path) != null;

  collect = d:
    let
      entries = builtins.readDir d;
    in
    builtins.concatMap
      (name:
        let path = d + "/${name}";
        in
        if entries.${name} == "directory"
        then collect path
        else if builtins.match ".*\\.nix" name != null
        then [ path ]
        else [ ])
      (builtins.attrNames entries);

  files = builtins.filter (p: !isHidden p) (collect dir);
in
_: { imports = files; }
