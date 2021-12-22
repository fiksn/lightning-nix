{ pkgs, buildGoModule, fetchurl, lib }:

buildGoModule rec {
  pname = "lightning-loop";
  version = "0.16.0-beta";

  src = fetchurl {
    url = "https://github.com/lightninglabs/loop/releases/download/v${version}/loop-source-v${version}.tar.gz";
    sha256 = "097x128k6g93s3hpdss5i28i7ai9zmrvpwimq3i55a7hi6qgvdch";
  };

  # tarball contains multiple files/directories

  preBuild = ''
    mkdir loop-src
    mv * loop-src || true
    cd loop-src
  '';

  sourceRoot = ".";

  subPackages = [ "cmd/loop" "cmd/loopd" ];

  vendorSha256 = "14862603rrss14p537j9i7iwflaaprwrnslmqm9hpb7hj52bxqfv";

  meta = with lib; {
    description = "Lightning Loop: A Non-Custodial Off/On Chain Bridge";
    homepage = "https://github.com/lightninglabs/loop";
    license = lib.licenses.mit;
  };
}
