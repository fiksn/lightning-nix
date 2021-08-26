{ pkgs, buildGoModule, fetchurl, lib }:

buildGoModule rec {
  pname = "lightning-loop";
  version = "0.11.0-beta";

  src = fetchurl {
    url = "https://github.com/lightninglabs/loop/releases/download/v${version}/loop-source-v${version}.tar.gz";
    # Use ./get-sha256.sh to fetch latest (verified) sha256
    sha256 = "sha256-fWYYl6dnJqxNpdQjwjn86DHF9pr8f1doZnEVVTyCWII=";
  };

  # tarball contains multiple files/directories

  preBuild = ''
    mkdir loop-src
    mv * loop-src || true
    cd loop-src
  '';

  sourceRoot = ".";

  subPackages = [ "cmd/loop" "cmd/loopd" ];

  vendorSha256 = "sha256-lMQsoL+u//MJtHa9bINIsShq479iChLKyUjJM92ujM8=";

  meta = with lib; {
    description = "Lightning Loop: A Non-Custodial Off/On Chain Bridge";
    homepage = "https://github.com/lightninglabs/loop";
    license = lib.licenses.mit;
  };
}
