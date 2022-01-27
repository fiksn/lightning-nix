{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem
, fetchFromGitHub
}:
let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  src = fetchFromGitHub {
    owner = "alexbosworth";
    repo = "balanceofsatoshis";
    rev = "v11.19.0";
    sha256 = "0jiq854xkbx06pl4x6p4033xq98y0ggm3rimf6iqj1alq3s96m05";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    buildInputs = [ pkgs.nodePackages.node-pre-gyp ];
    src = src;
  };
}
