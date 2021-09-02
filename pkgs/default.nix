{ pkgs ? import <nixpkgs> { }, pkgs-unstable ? pkgs }:
with pkgs;
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

  aperture = callPackage ./aperture { };

  btcpayserver = pkgs-unstable.btcpayserver;
  nbxplorer = pkgs-unstable.nbxplorer;
  lightning-loop = callPackage ./lightning-loop { };
  lightning-pool = callPackage ./lightning-pool { };
  balanceofsatoshis = (callPackage ./balanceofsatoshis/override.nix { }).package;

  #lightning-terminal = callPackage ./lightning-terminal { };
}
