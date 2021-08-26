{ stdenv, lib, callPackage, dotnet-sdk_3, fetchFromGitHub }:
let
  dotnet = callPackage ./dotnet-build.nix {
    dotnet-sdk = dotnet-sdk_3;
  };
in
dotnet.mkDotNetCoreProject rec {
  project = "NBXplorer";
  version = "2.1.47";
  nugetPackages = lib.importJSON (./. + "/nbxplorer-packages.json");

  src = fetchFromGitHub {
    owner = "dgarage";
    repo = "NBXplorer";
    rev = "v2.1.47";
    sha256 = "TigWWr9KOkeYQK0W4egkrtOaijnz40Ljx27VnJ1jyjM=";
  };

  meta = with lib; {
    description = "dotnet Bitcoin chain source for BTCPayServer";
    license = licenses.mit;
    maintainers = [ maintainers.jb55 ];
    platforms = with platforms; linux;
  };
}
