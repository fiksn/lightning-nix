{ buildGoModule
, fetchFromGitHub
, lib
, tags ? [ "autopilotrpc" "signrpc" "walletrpc" "chainrpc" "invoicesrpc" "watchtowerrpc" ]
}:

buildGoModule rec {
  pname = "lnd";
  version = "0.15.2-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "0jdlccjl222wzz3nrd8ykb4110dj520xjxgqpragxnhqmklmkc0b";
  };

  vendorSha256 = "1fy51srn02ajm6axp8i0l56dikn28lmc4z7i5pgw059b90z5q9xc";

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
