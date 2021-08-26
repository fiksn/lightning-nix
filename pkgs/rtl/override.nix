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
    rev = "be9050aee2f4db061c870cbc73b872b03debc146";
    sha256 = "15fnldxwqk13swl893qk6zg03crv1pzfganafgaga9allhpjxyfl";
  };
in
nodePackages // {
  package = nodePackages.package.override {
    src = src;
  };
}
