{ buildGoModule
, fetchFromGitHub
, lib
, tags ? [ "autopilotrpc" "signrpc" "walletrpc" "chainrpc" "invoicesrpc" "watchtowerrpc" ]
}:

buildGoModule rec {
  pname = "lnd";
  version = "0.15.4-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "1mshfsq6dn2j66yq7knhqyl52mlbqlqy0hnayfj5agmyivcrdwpw";
  };

  vendorSha256 = "13xz1m9kmkyaqqn7kgqf1fn8pxld9h9ba5qhgqcin5jf3cz38jkd";

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
