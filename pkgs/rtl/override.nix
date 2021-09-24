{ pkgs ? import <nixpkgs> { }
, system ? builtins.currentSystem
, fetchFromGitHub
}:
let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  src = fetchFromGitHub {
    owner = "Ride-The-Lightning";
    repo = "RTL";
    rev = "v0.11.2";
    sha256 = "03cc21z45bm0f8qmhzaaw305mvph6bdxck8cybhh1nihbjmr7ffv";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    src = src;
  };
}
