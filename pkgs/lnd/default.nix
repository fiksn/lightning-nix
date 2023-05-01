{ buildGoModule
, fetchFromGitHub
, lib
, tags ? [ "autopilotrpc" "signrpc" "walletrpc" "chainrpc" "invoicesrpc" "watchtowerrpc" ]
}:

buildGoModule rec {
  pname = "lnd";
  version = "0.16.2-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "0vfd3qpi5nz85w48ds10978qbsgvj1sfygmxcn5ixf3x5xlvyjdk";
  };

  vendorSha256 = "1zdfaknl23jab1wl2bhh73gskz0gwdf9hnjl8c0y6s3slvknb1zd";

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
