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
    rev = "a91c46071129cc115f81302847dba3d8516670d9";
    sha256 = "0bliylyj2p0c1x3qn4xag1372y0chgnb5j9pnlgyaq9pgyw6nz5b";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    buildInputs = [ pkgs.nodePackages.node-pre-gyp ];
    src = src;
  };
}
