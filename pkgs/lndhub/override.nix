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
    rev = "v1.3.0";
    sha256 = "09ygh99m802znqgqs7szrfh4nla1qn4zag3rk2jgvp4l4snbf89p";
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
