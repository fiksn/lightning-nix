{ pkgs ? import <nixpkgs> { }, pkgs-unstable ? pkgs }:
with pkgs;
let
  depPlatformsAll = inp: builtins.map (x: x.meta.platforms or [ ]) inp;
  depWithOrig = orig: inp: (depPlatformsAll inp) ++ orig;
  intersectAll = lol: lib.foldl' (acc: one: if one != [ ] then (lib.intersectLists acc one) else acc) lib.platforms.all lol;
in
{
  rtl = (callPackage ./rtl/override.nix { }).package;
  lndhub = (callPackage ./lndhub/override.nix { }).package;
  lndconnect = callPackage ./lndconnect { };
  lnbits = callPackage ./lnbits { };
  lnd = callPackage ./lnd { };
  bitcoind = bitcoind.overrideAttrs (old: rec {
    version = "22.0";
    src = fetchurl {
      urls = [
        "https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
      ];
      sha256 = "d0e9d089b57048b1555efa7cd5a63a7ed042482045f6f33402b1df425bf9613b";
    };
  });

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
}
