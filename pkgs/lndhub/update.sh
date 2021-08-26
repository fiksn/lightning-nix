#! /bin/sh

OWNER=BlueWallet
REPO=LndHub
REVISION=${REVISION:-"v1.3.0"}
COMMIT=$(git ls-remote https://github.com/$OWNER/$REPO.git $REVISION | cut -f 1)
rm -f package.json package-lock.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$REVISION/package.json
wget https://raw.githubusercontent.com/$OWNER/$REPO/$REVISION/package-lock.json
node2nix -i package.json -l package-lock.json
rm -f package.json package-lock.json
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
    rev = "$REVISION";
    sha256 = "$HASH";
  };
in
nodePackages // {
 package = nodePackages.package.override {
    src = src;
    # Expected directory: node-v72-linux-arm64-unknown Found: [node-v72-linux-arm64-glibc]
    npmFlags = "--target_libc=unknown";
    # Make sure babel is invoked at build time
    postInstall = ''
      ./node_modules/.bin/babel . --out-dir ./build --copy-files --ignore node_modules
    '';
  };
}
EOF
