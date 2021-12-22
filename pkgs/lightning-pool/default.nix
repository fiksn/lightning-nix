{ pkgs, buildGoModule, fetchurl, lib }:

buildGoModule rec {
  pname = "lightning-pool";
  version = "0.5.3-alpha";

  src = fetchurl {
    url = "https://github.com/lightninglabs/pool/releases/download/v${version}/pool-source-v${version}.tar.gz";
    sha256 = "1ragimcv6cia46zh71c6rhg0jzryn2kmc7iq719b41f9h97i60qg";
  };

  doCheck = false;

  # tarball contains multiple files/directories
  preBuild = ''
    mkdir pool-src
    mv * pool-src || true
    cd pool-src
  '';

  sourceRoot = ".";

  subPackages = [ "cmd/pool" "cmd/poold" ];

  vendorSha256 = "09yxaa74814l1rp0arqhqpplr2j0p8dj81zqcbxlwp5ckjv9r2za";

  meta = with lib; {
    description = "Lightning Pool: A non-custodial batched uniform clearing-price auction for Lightning Channel Leases (LCL).";
    homepage = "https://github.com/lightninglabs/pool";
    license = lib.licenses.mit;
  };
}
