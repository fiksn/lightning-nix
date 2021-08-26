{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  requirements = callPackages ./requirements.nix { };
  clean = lib.filterAttrs (n: v: n != "override" && n != "overrideDerivation") requirements.packages;
  deps = builtins.attrValues clean;
  quart = requirements.packages."quart";
  hypercorn = requirements.packages."hypercorn";
in
python3Packages.buildPythonApplication rec {
  namePrefix = "";
  name = "lnbits";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "lnbits";
    repo = "lnbits";
    rev = "${version}";
    sha256 = "1kcvls7pkh18xzs7h1r5izxng4zsjv4lbadihv8qwkj5x0mkg2i6";
  };

  format = "other";

  doCheck = false;
  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out

    # We just need two binaries quart and hypercorn
    makeWrapper ${quart}/bin/quart $out/bin/quart \
      --prefix PATH : ${lib.makeBinPath [ quart ]} \
      --prefix PYTHONPATH : ${lib.concatStringsSep ":" (map (p: p + "/lib/${python3.libPrefix}/site-packages") (python3.pkgs.requiredPythonModules deps))}

    makeWrapper ${hypercorn}/bin/hypercorn $out/bin/hypercorn \
      --prefix PATH : ${lib.makeBinPath [ hypercorn ]} \
      --prefix PYTHONPATH : ${lib.concatStringsSep ":" (map (p: p + "/lib/${python3.libPrefix}/site-packages") (python3.pkgs.requiredPythonModules deps))}
  '';

  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = deps;
  propagatedNativeBuildInputs = deps;
}
