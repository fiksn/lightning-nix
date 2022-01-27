{ lib, buildPythonPackage, fetchPypi, importlib-resources }:
buildPythonPackage rec {
  pname = "yachalk";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "12krk729xmrn9wms0wn3zzarvkdf0hb2zs7xml30ya4a35mbdhya";
  };

  nativeBuildInputs = [
    importlib-resources
  ];

  doCheck = false;

  meta = with lib; {
    description = "Yet Another Chalk - terminal string styling done right";
    homepage = "https://github.com/bluenote10/yachalk";
    license = licenses.mit;
  };
}
