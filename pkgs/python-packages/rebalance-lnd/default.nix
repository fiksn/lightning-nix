{ lib, stdenv, fetchFromGitHub, buildPythonPackage, grpcio, protobuf, six, yachalk, google-api-python-client }:

buildPythonPackage rec {
  pname = "rebalance-lnd";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "C-Otto";
    repo = "rebalance-lnd";
    rev = "v${version}";
    sha256 = "0d71qwjs13jvbxhfbzi79l83c11ffrbra5fsvklvprwgnxvca7gq";
  };

  doCheck = false;

  format = "other";

  propagatedBuildInputs = [
    yachalk
    grpcio
    protobuf
    six
    google-api-python-client
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp *.py $out/bin
    cp -r grpc_generated $out/bin/grpc_generated
  '';

  meta = with lib; {
    description = "A script that can be used to balance lightning channels of a lnd node";
    homepage = "https://github.com/C-Otto/rebalance-lnd";
    license = licenses.mit;
  };
}
