#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git wget nodePackages.node2nix nix

OWNER=alexbosworth
REPO=balanceofsatoshis
REVISION=${REVISION:-"HEAD"}
COMMIT=$(git ls-remote https://github.com/$OWNER/$REPO.git $REVISION | cut -f 1)
rm -f package.json package-lock.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$COMMIT/package.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$COMMIT/package-lock.json
node2nix -i package.json -l package-lock.json
rm -f package.json package-lock.json
HASH=$(nix-prefetch-url --unpack https://github.com/$OWNER/$REPO/archive/$COMMIT.tar.gz)

cat << EOF
{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem,
fetchFromGitHub
}:
let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  src = fetchFromGitHub {
    owner = "$OWNER";
    repo = "$REPO";
    rev = "$COMMIT";
    sha256 = "$HASH";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    buildInputs = [ pkgs.nodePackages.node-pre-gyp ];
    src = src;
  };
}
EOF
