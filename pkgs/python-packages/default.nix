pkgs: self: super:
let
  inherit (self) callPackage;
in
{
  rebalance-lnd = callPackage ./rebalance-lnd { };
  yachalk = callPackage ./yachalk { };
}
