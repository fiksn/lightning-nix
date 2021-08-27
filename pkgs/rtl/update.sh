#! /bin/sh

OWNER=Ride-The-Lightning
REPO=RTL
REVISION=${REVISION:-"v0.11.0"}
COMMIT=$(git ls-remote https://github.com/$OWNER/$REPO.git $REVISION | cut -f 1)
rm -f package.json package-lock.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$REVISION/package.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$REVISION/package-lock.json
node2nix -i package.json -l package-lock.json
#rm -f package.json package-lock.json
HASH=$(nix-prefetch-url --unpack https://github.com/$OWNER/$REPO/archive/$REVISION.tar.gz)

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
    src = src;
  };
}
EOF
