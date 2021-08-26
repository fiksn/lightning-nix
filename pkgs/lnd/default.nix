{ buildGoModule
, fetchFromGitHub
, lib
, tags ? [ "autopilotrpc" "signrpc" "walletrpc" "chainrpc" "invoicesrpc" "watchtowerrpc" ]
}:

buildGoModule rec {
  pname = "lnd";
  version = "0.13.1-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "b+5IqSscBf7dOg+Tx8dBeETlpuuCbMddlUrRgbBPmh0=";
  };

  vendorSha256 = "Kn5FhcG4nmWE9w46OgEjdwgDI/cQTfRuqBwwalE/ZsI=";

  doCheck = false;

  subPackages = [ "cmd/lncli" "cmd/lnd" ];

  preBuild =
    let
      buildVars = {
        RawTags = lib.concatStringsSep "," tags;
        GoVersion = "$(go version | egrep -o 'go[0-9]+[.][^ ]*')";
      };
      buildVarsFlags = lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "-X github.com/lightningnetwork/lnd/build.${k}=${v}") buildVars);
    in
    lib.optionalString (tags != [ ]) ''
      buildFlagsArray+=("-tags=${lib.concatStringsSep " " tags}")
      buildFlagsArray+=("-ldflags=${buildVarsFlags}")
    '';

  meta = with lib; {
    description = "Lightning Network Daemon";
    homepage = "https://github.com/lightningnetwork/lnd";
    license = lib.licenses.mit;
    maintainers = with maintainers; [ cypherpunk2140 ];
  };
}
