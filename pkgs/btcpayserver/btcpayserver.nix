{ stdenv, lib, callPackage, dotnet-sdk_3, fetchFromGitHub }:
let
  dotnet = callPackage ./dotnet-build.nix {
    dotnet-sdk = dotnet-sdk_3;
  };
in
dotnet.mkDotNetCoreProject rec {
  project = "BTCPayServer";
  version = "1.0.6.7";
  nugetPackages = lib.importJSON (./. + "/btcpayserver-packages.json");

  src = fetchFromGitHub {
    owner = "btcpayserver";
    repo = "btcpayserver";
    rev = "v1.0.6.7";
    sha256 = "nlMERRDksB9OWWxWLDn528YPW0n6za50UhEjVLSt+q8=";
  };

  meta = with lib; {
    description = "Bitcoin payment server";
    license = licenses.mit;
    maintainers = [ maintainers.jb55 ];
    platforms = with platforms; linux;
  };
}
