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
  lnd = (callPackage ./lnd { });

  bitcoind-fullrbf = bitcoind.overrideAttrs (old: rec {
    version = "25.0-fullrbf";
    src = pkgs.fetchFromGitHub { owner = "petertodd"; repo = "bitcoin"; rev = "full-rbf-v25.0"; sha256 = "10n1l0y3wpnzp4irxndc75l4lijlqcclgpslb5kbdyiql8wb8x7j"; };
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
  lightning-terminal = callPackage ./lightning-terminal { };

  balanceofsatoshis = (callPackage ./balanceofsatoshis/override.nix { }).package;


  ### Lightning address stuff - https://lightningaddress.com/
  lnme = callPackage ./lnme { };
  satdress = callPackage ./satdress { };

  inherit python3Packages;

  rebalance-lnd = python3Packages.rebalance-lnd;
}
