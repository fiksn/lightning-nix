{ pkgs ? import <nixpkgs> { }, pkgs-unstable ? pkgs }:
with pkgs;
let
  depPlatformsAll = inp: builtins.map (x: x.meta.platforms or [ ]) inp;
  depWithOrig = orig: inp: (depPlatformsAll inp) ++ orig;
  intersectAll = lol: lib.foldl' (acc: one: if one != [ ] then (lib.intersectLists acc one) else acc) lib.platforms.all lol;

  python3Packages = (pkgs.python3.override {
    packageOverrides = import ./python-packages self;
  }).pkgs;
in
{
  rtl = (callPackage ./rtl/override.nix { }).package;
  lndhub = (callPackage ./lndhub/override.nix { }).package;
  lndconnect = callPackage ./lndconnect { };
  lnbits = callPackage ./lnbits { };
  lnd = callPackage ./lnd { };

  bitcoind = bitcoind.overrideAttrs (old: rec {
    version = "0.21.1";
    src = fetchurl {
      urls = [
        "https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
        "https://bitcoin.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
      ];
      sha256 = "sha256-yv8jRJIgz0V1PzEs7+3lOp6sZAALswB5eRZSYja2oeA=";
    };
  });

  bitcoind-22 = bitcoind.overrideAttrs (old: rec {
    version = "22.0";
    src = fetchurl {
      urls = [
        "https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
      ];
      sha256 = "d0e9d089b57048b1555efa7cd5a63a7ed042482045f6f33402b1df425bf9613b";
    };
  });

  bitcoind-unstable = pkgs-unstable.bitcoind;

  aperture = callPackage ./aperture { };

  # Fix broken platforms
  btcpayserver = pkgs-unstable.btcpayserver.overrideAttrs (attrs: {
    meta = attrs.meta // { platforms = intersectAll (depWithOrig ([ attrs.meta.platforms or lib.platforms.linux ]) (attrs.nativeBuildInputs or [ ])); };
  });
  nbxplorer = pkgs-unstable.nbxplorer.overrideAttrs (attrs: {
    meta = attrs.meta // { platforms = intersectAll (depWithOrig ([ attrs.meta.platforms or lib.platforms.linux ]) (attrs.nativeBuildInputs or [ ])); };
  });

  lightning-loop = callPackage ./lightning-loop { };
  lightning-pool = callPackage ./lightning-pool { };
  balanceofsatoshis = (callPackage ./balanceofsatoshis/override.nix { }).package;

  #lightning-terminal = callPackage ./lightning-terminal { };

  ### Lightning address stuff - https://lightningaddress.com/
  lnme = callPackage ./lnme { };
  satdress = callPackage ./satdress { };

  inherit python3Packages;

  rebalance-lnd = python3Packages.rebalance-lnd;
}
