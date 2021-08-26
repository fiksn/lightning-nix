{ stdenv, fetchFromGitHub, git, buildGoPackage }:

buildGoPackage rec {
  pname = "lndconnect";

  version = "v0.2.0";
  goPackagePath = "github.com/LN-Zap/lndconnect";

  src = fetchFromGitHub {
    owner = "LN-Zap";
    repo = "lndconnect";
    rev = "v0.2.0";
    sha256 = "0zp23vp4i4csc6x1b6z39rqcmknxd508x6clr8ckdj2fwjwkyf5a";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    homepage = "https://github.com/LN-Zap/lndconnect";
    license = licenses.mit;
  };
}
