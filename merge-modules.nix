{nixpkgs
}:
modules : pkgs :
let evalModules = nixpkgs.lib.evalModules;
in (evalModules {
  modules =
    [
      { _module.args = { inherit pkgs; lib = pkgs.lib; }; }
    ] ++ modules;
}).config
