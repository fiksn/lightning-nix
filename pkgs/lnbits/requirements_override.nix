{ pkgs, python }:

with pkgs.lib;
with builtins;

self: super:
let
  filterValid = filterAttrs (name: value: hasAttr name super);
in
filterValid {
  "quart-compress" =
    super."quart-compress".overrideDerivation (old: { buildInputs = old.buildInputs ++ [ self."pytest-runner" ]; });

  "httpx" =
    super."httpx".overrideDerivation (old: { buildInputs = old.buildInputs ++ [ self."idna" ]; });
} // {
  "setuptools-scm" = python.mkDerivation {
    name = "setuptools-scm-5.0.1";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/af/df/f8aa8a78d4d29e0cffa4512e9bc223ed02f24893fe1837c6cee2749ebd67/setuptools_scm-5.0.1.tar.gz";
      sha256 = "c85b6b46d0edd40d2301038cdea96bb6adc14d62ef943e75afb08b3e7bcf142a";
    };
    doCheck = false;
    format = "pyproject";
    buildInputs = [
      self."setuptools"
      self."wheel"
    ];
    propagatedBuildInputs = [
      self."setuptools"
    ];
    meta = with lib; {
      homepage = "https://github.com/pypa/setuptools_scm/";
      license = licenses.mit;
      description = "the blessed package to manage your versions by scm tags";
    };
  };

  "pytest-runner" = python.mkDerivation {
    name = "pytest-runner-5.2";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/5b/82/1462f86e6c3600f2471d5f552fcc31e39f17717023df4bab712b4a9db1b3/pytest-runner-5.2.tar.gz";
      sha256 = "96c7e73ead7b93e388c5d614770d2bae6526efd997757d3543fe17b557a0942b";
    };
    doCheck = false;
    format = "pyproject";
    buildInputs = [
      self."setuptools"
      self."setuptools-scm"
      self."wheel"
    ];
    propagatedBuildInputs = [ ];
    meta = with lib; {
      homepage = "https://github.com/pytest-dev/pytest-runner/";
      license = licenses.mit;
      description = "Invoke py.test as distutils command with dependency resolution";
    };
  };
}
