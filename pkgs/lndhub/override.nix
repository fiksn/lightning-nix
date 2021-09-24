{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem
, fetchFromGitHub
}:
let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  src = fetchFromGitHub {
    owner = "BlueWallet";
    repo = "LndHub";
    rev = "v1.4.0";
    sha256 = "0z3vrbgx2vzyg3i2zsl3x4jrkqvl5x05287pi3qf56qra6wnbqia";
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
