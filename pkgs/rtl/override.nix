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
    rev = "4ac6d88c6967f4d7ddaa20cdcbe2dce343566501";
    sha256 = "1x7il58h5ccxam8blcvrywwpqj19bdhrda9gvdbvhsrynmbri8yr";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    src = src;
  };
}
