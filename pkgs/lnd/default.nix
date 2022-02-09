{ buildGoModule
, fetchFromGitHub
, lib
, tags ? [ "autopilotrpc" "signrpc" "walletrpc" "chainrpc" "invoicesrpc" "watchtowerrpc" ]
}:

buildGoModule rec {
  pname = "lnd";
  version = "0.14.2-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "1m59xhzw2m0k7dmh13pxykcli6a9f9xda48njx33jwan3jvs5qi4";
  };

  vendorSha256 = "1cjgvgprjnwxw3r7zc6z0z62fr6q330iqk0x48xvd89jq4jyc45j";

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
