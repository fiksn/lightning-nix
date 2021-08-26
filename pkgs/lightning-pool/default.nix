{ pkgs, buildGoModule, fetchurl, lib }:

buildGoModule rec {
  pname = "lightning-pool";
  version = "0.3.2-alpha";

  src = fetchurl {
    url = "https://github.com/lightninglabs/pool/releases/download/v${version}/pool-source-v${version}.tar.gz";
    sha256 = "sha256-Vvy2ExW5gejvmRtd5DPesBj9pKHcZY7RyxF/xzM9H6k=";
  };

  # tarball contains multiple files/directories

  preBuild = ''
    mkdir pool-src
    mv * pool-src || true
    cd pool-src
  '';

  sourceRoot = ".";

  subPackages = [ "cmd/pool" "cmd/poold" ];

  vendorSha256 = "sha256-njJcE5nDKtzmJqbLoKx7qWa+9oeRYR4WwFcOxk/WPNs=";

  meta = with lib; {
    description = "Lightning Pool: A non-custodial batched uniform clearing-price auction for Lightning Channel Leases (LCL).";
    homepage = "https://github.com/lightninglabs/pool";
    license = lib.licenses.mit;
  };
}
