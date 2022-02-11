# generated using pypi2nix tool (version: 2.0.4)
# See more at: https://github.com/nix-community/pypi2nix
#
# COMMAND:
#   pypi2nix -r requirements.txt -e lndgrpc
#

{ pkgs ? import <nixpkgs> { }
, overrides ? ({ pkgs, python }: self: super: { })
, lib
}:
let
  inherit (pkgs) makeWrapper;
  inherit (lib) fix' extends inNixShell;

  pythonPackagesImport = import "${toString pkgs.path}/pkgs/top-level/python-packages.nix";
  needsLib = builtins.elem "lib" (pkgs.lib.attrNames (builtins.functionArgs pythonPackagesImport));
  pythonPackages' = pythonPackagesImport ({
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python3;
  } // (if needsLib then { inherit (pkgs) lib; } else { }));
  pythonPackages = if builtins.isFunction pythonPackages' then pkgs.lib.makeScope pkgs.newScope pythonPackages' else pythonPackages';

  commonBuildInputs = [ ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' [ "__unfix__" ];
      interpreterWithPackages = selectPkgsFn: pythonPackages.buildPythonPackage {
        name = "python3-interpreter";
        buildInputs = [ makeWrapper ] ++ (selectPkgsFn pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
            (selectPkgsFn pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable} \
              python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };

      interpreter = interpreterWithPackages builtins.attrValues;
    in
    {
      __old = pythonPackages;
      inherit interpreter;
      inherit interpreterWithPackages;
      mkDerivation = args: pythonPackages.buildPythonPackage (args // {
        nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ args.buildInputs;
      });
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages { };

  generated = self: {
    "aiofiles" = python.mkDerivation {
      name = "aiofiles-0.6.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/77/47/19e5951cc6ed771669906d2946b3deac32a35a9a155f730be49d8fa73dc9/aiofiles-0.6.0.tar.gz";
        sha256 = "e0281b157d3d5d59d803e3f4557dcc9a3dff28a4dd4829a9ff478adae50ca092";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/Tinche/aiofiles";
        license = licenses.asl20;
        description = "File support for asyncio.";
      };
    };

    "aiogrpc" = python.mkDerivation {
      name = "aiogrpc-1.8";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/e5/65/00e94dc69fccd7f1f829cc140ab285b1deb9e13a844a88be83d042ca3a78/aiogrpc-1.8.tar.gz";
        sha256 = "472155a52850bd4b9493a994079f9c12c65324f02fe6466e636470127fc32aaf";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."grpcio"
      ];
      meta = with lib; {
        homepage = "https://github.com/hubo1016/aiogrpc";
        license = licenses.mit;
        description = "asyncio wrapper for grpc.io";
      };
    };

    "async-generator" = python.mkDerivation {
      name = "async-generator-1.10";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ce/b6/6fa6b3b598a03cba5e80f829e0dadbb49d7645f523d209b2fb7ea0bbb02a/async_generator-1.10.tar.gz";
        sha256 = "6ebb3d106c12920aaae42ccb6f787ef5eefdcdd166ea3d628fa8476abe712144";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python-trio/async_generator";
        license = licenses.mit;
        description = "Async generators and context managers for Python 3.5+";
      };
    };

    "attrs" = python.mkDerivation {
      name = "attrs-20.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/f0/cb/80a4a274df7da7b8baf083249b0890a0579374c3d74b5ac0ee9291f912dc/attrs-20.3.0.tar.gz";
        sha256 = "832aa3cde19744e49938b91fea06d69ecb9e649c93ba974535d08ad92164f700";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
        self."wheel"
      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://www.attrs.org/";
        license = licenses.mit;
        description = "Classes Without Boilerplate";
      };
    };

    "bech32" = python.mkDerivation {
      name = "bech32-1.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ab/fe/b67ac9b123e25a3c1b8fc3f3c92648804516ab44215adb165284e024c43f/bech32-1.2.0.tar.gz";
        sha256 = "7d6db8214603bd7871fcfa6c0826ef68b85b0abd90fa21c285a9c5e21d2bd899";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/fiatjaf/bech32";
        license = licenses.mit;
        description = "Reference implementation for Bech32 and segwit addresses.";
      };
    };

    "bitstring" = python.mkDerivation {
      name = "bitstring-3.1.7";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c3/fc/ffac2c199d2efe1ec5111f55efeb78f5f2972456df6939fea849f103f9f5/bitstring-3.1.7.tar.gz";
        sha256 = "fdf3eb72b229d2864fb507f8f42b1b2c57af7ce5fec035972f9566de440a864a";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/scott-griffiths/bitstring";
        license = licenses.mit;
        description = "Simple construction, analysis and modification of binary data.";
      };
    };

    "blinker" = python.mkDerivation {
      name = "blinker-1.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/1b/51/e2a9f3b757eb802f61dc1f2b09c8c99f6eb01cf06416c0671253536517b6/blinker-1.4.tar.gz";
        sha256 = "471aee25f3992bd325afa3772f1063dbdbbca947a041b8b89466dc00d606f8b6";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "http://pythonhosted.org/blinker/";
        license = licenses.mit;
        description = "Fast, simple object-to-object and broadcast signaling";
      };
    };

    "brotli" = python.mkDerivation {
      name = "brotli-1.0.9";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/2a/18/70c32fe9357f3eea18598b23aa9ed29b1711c3001835f7cf99a9818985d0/Brotli-1.0.9.zip";
        sha256 = "4d1b810aa0ed773f81dceda2cc7b403d01057458730e309856356d4ef4188438";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/google/brotli";
        license = licenses.mit;
        description = "Python bindings for the Brotli compression library";
      };
    };

    "cerberus" = python.mkDerivation {
      name = "cerberus-1.3.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/90/a7/71c6ed2d46a81065e68c007ac63378b96fa54c7bb614d653c68232f9c50c/Cerberus-1.3.2.tar.gz";
        sha256 = "302e6694f206dd85cb63f13fd5025b31ab6d38c99c50c6d769f8fa0b0f299589";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."setuptools"
      ];
      meta = with lib; {
        homepage = "http://docs.python-cerberus.org";
        license = licenses.isc;
        description = "Lightweight, extensible schema and data validation tool for Python dictionaries.";
      };
    };

    "certifi" = python.mkDerivation {
      name = "certifi-2020.11.8";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/e6/de/879cf857ae6f890dfa23c3d6239814c5471936b618c8fb0c8732ad5da885/certifi-2020.11.8.tar.gz";
        sha256 = "f05def092c44fbf25834a51509ef6e631dc19765ab8a57b4e7ab85531f0a9cf4";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://certifiio.readthedocs.io/en/latest/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };

    "click" = python.mkDerivation {
      name = "click-7.1.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/27/6f/be940c8b1f1d69daceeb0032fee6c34d7bd70e3e649ccac0951500b4720e/click-7.1.2.tar.gz";
        sha256 = "d2b5255c7c6349bc1bd1e59e08cd12acbbd63ce649f2588755783aa94dfb6b1a";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://palletsprojects.com/p/click/";
        license = licenses.bsdOriginal;
        description = "Composable command line interface toolkit";
      };
    };

    "ecdsa" = python.mkDerivation {
      name = "ecdsa-0.16.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/1d/d4/0684a83b3c16a9d1446ace27a506cef1db9b23984ac7ed6aaf764fdd56e8/ecdsa-0.16.1.tar.gz";
        sha256 = "cfc046a2ddd425adbd1a78b3c46f0d1325c657811c0f45ecc3a0a6236c1e50ff";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with lib; {
        homepage = "http://github.com/warner/python-ecdsa";
        license = licenses.mit;
        description = "ECDSA cryptographic signature library (pure python)";
      };
    };

    "environs" = python.mkDerivation {
      name = "environs-9.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/1c/35/cbd3d98cac25a88c1ae6378d9c0b8921de43a6bc014bc623c18168994e0b/environs-9.2.0.tar.gz";
        sha256 = "36081033ab34a725c2414f48ee7ec7f7c57e498d8c9255d61fbc7f2d4bf60865";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."marshmallow"
        self."python-dotenv"
      ];
      meta = with lib; {
        homepage = "https://github.com/sloria/environs";
        license = licenses.mit;
        description = "simplified environment variable parsing";
      };
    };

    "googleapis-common-protos" = python.mkDerivation {
      name = "googleapis-common-protos-1.52.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/95/3f/a1282d82def57e0c28bab597d25785774a4e64433aac9cc136e65c500da8/googleapis-common-protos-1.52.0.tar.gz";
        sha256 = "560716c807117394da12cecb0a54da5a451b5cf9866f1d37e9a5e2329a665351";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."protobuf"
      ];
      meta = with lib; {
        homepage = "https://github.com/googleapis/python-api-common-protos";
        license = licenses.asl20;
        description = "Common protobufs used in Google APIs";
      };
    };

    "grpcio" = python.mkDerivation {
      name = "grpcio-1.35.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/20/4b/0b810309628e354f53b3c90af063f268d74e49902a41196db27f1fb52f06/grpcio-1.35.0.tar.gz";
        sha256 = "7bd0ebbb14dde78bf66a1162efd29d3393e4e943952e2f339757aa48a184645c";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with lib; {
        homepage = "https://grpc.io";
        license = licenses.asl20;
        description = "HTTP/2-based RPC framework";
      };
    };

    "grpcio-tools" = python.mkDerivation {
      name = "grpcio-tools-1.35.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/82/09/7cc18fe0712a5fbc77fdf5b3bd61ed9618216700e8d49ab23431f5e44370/grpcio-tools-1.35.0.tar.gz";
        sha256 = "9e2a41cba9c5a20ae299d0fdd377fe231434fa04cbfbfb3807293c6ec10b03cf";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."grpcio"
        self."protobuf"
        self."setuptools"
      ];
      meta = with lib; {
        homepage = "https://grpc.io";
        license = licenses.asl20;
        description = "Protobuf code generator for gRPC";
      };
    };

    "h11" = python.mkDerivation {
      name = "h11-0.11.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/22/01/01dc716e71eeead6c6329a19028548ac4a5c2a769a130722548c63479038/h11-0.11.0.tar.gz";
        sha256 = "3c6c61d69c6f13d41f1b80ab0322f1872702a3ba26e12aa864c928f6a43fbaab";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python-hyper/h11";
        license = licenses.mit;
        description = "A pure-Python, bring-your-own-I/O implementation of HTTP/1.1";
      };
    };

    "h2" = python.mkDerivation {
      name = "h2-4.0.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/05/b8/cc1692aab910c0319b7c35e03c043bdda1cfeff67fa25b555eb2864a36e3/h2-4.0.0.tar.gz";
        sha256 = "bb7ac7099dd67a857ed52c815a6192b6b1f5ba6b516237fc24a085341340593d";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."hpack"
        self."hyperframe"
      ];
      meta = with lib; {
        homepage = "https://github.com/python-hyper/hyper-h2";
        license = licenses.mit;
        description = "HTTP/2 State-Machine based protocol implementation";
      };
    };

    "hpack" = python.mkDerivation {
      name = "hpack-4.0.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/3e/9b/fda93fb4d957db19b0f6b370e79d586b3e8528b20252c729c476a2c02954/hpack-4.0.0.tar.gz";
        sha256 = "fc41de0c63e687ebffde81187a948221294896f6bdc0ae2312708df339430095";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python-hyper/hpack";
        license = licenses.mit;
        description = "Pure-Python HPACK header compression";
      };
    };

    "httpcore" = python.mkDerivation {
      name = "httpcore-0.12.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/9f/32/0001b9ebc116f78df57428cc9971e9dd518baa3b5b754d7685866837051e/httpcore-0.12.2.tar.gz";
        sha256 = "dd1d762d4f7c2702149d06be2597c35fb154c5eff9789a8c5823fbcf4d2978d6";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."h11"
        self."sniffio"
      ];
      meta = with lib; {
        homepage = "https://github.com/encode/httpcore";
        license = licenses.bsdOriginal;
        description = "A minimal low-level HTTP client.";
      };
    };

    "httpx" = python.mkDerivation {
      name = "httpx-0.16.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/28/1e/1726b212239edc78999874e0ba8c86baec99e5d36ccfae9911514feae80c/httpx-0.16.1.tar.gz";
        sha256 = "126424c279c842738805974687e0518a94c7ae8d140cd65b9c4f77ac46ffa537";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."certifi"
        self."httpcore"
        self."rfc3986"
        self."sniffio"
      ];
      meta = with lib; {
        homepage = "https://github.com/encode/httpx";
        license = licenses.bsdOriginal;
        description = "The next generation HTTP client.";
      };
    };

    "hypercorn" = python.mkDerivation {
      name = "hypercorn-0.11.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/07/ee/5913024fc60f7c7b3aa68a8e0b4fa6cf528d13c6fd00129298884c3574c9/Hypercorn-0.11.1.tar.gz";
        sha256 = "81c69dd84a87b8e8b3ebf06ef5dd92836a8238f0ac65ded3d86befb8ba9acfeb";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
        self."wheel"
      ];
      propagatedBuildInputs = [
        self."h11"
        self."h2"
        self."priority"
        self."toml"
        self."wsproto"
      ];
      meta = with lib; {
        homepage = "https://gitlab.com/pgjones/hypercorn/";
        license = licenses.mit;
        description = "A ASGI Server based on Hyper libraries and inspired by Gunicorn.";
      };
    };

    "hyperframe" = python.mkDerivation {
      name = "hyperframe-6.0.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/77/de/0b52ce363ab022f092abd82dca0f667a3b623f5f40d182e593fbc9113b4f/hyperframe-6.0.0.tar.gz";
        sha256 = "742d2a4bc3152a340a49d59f32e33ec420aa8e7054c1444ef5c7efff255842f1";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python-hyper/hyperframe/";
        license = licenses.mit;
        description = "HTTP/2 framing layer for Python";
      };
    };

    "idna" = python.mkDerivation {
      name = "idna-2.10";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ea/b7/e0e3c1c467636186c39925827be42f16fee389dc404ac29e930e9136be70/idna-2.10.tar.gz";
        sha256 = "b307872f855b18632ce0c21c5e45be78c0ea7ae4c15c828c20788b26921eb3f6";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "itsdangerous" = python.mkDerivation {
      name = "itsdangerous-1.1.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/68/1a/f27de07a8a304ad5fa817bbe383d1238ac4396da447fa11ed937039fa04b/itsdangerous-1.1.0.tar.gz";
        sha256 = "321b033d07f2a4136d3ec762eac9f16a10ccd60f53c0c91af90217ace7ba1f19";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://palletsprojects.com/p/itsdangerous/";
        license = licenses.bsdOriginal;
        description = "Various helpers to pass data to untrusted environments and back.";
      };
    };

    "jinja2" = python.mkDerivation {
      name = "jinja2-2.11.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/64/a7/45e11eebf2f15bf987c3bc11d37dcc838d9dc81250e67e4c5968f6008b6c/Jinja2-2.11.2.tar.gz";
        sha256 = "89aab215427ef59c34ad58735269eb58b1a5808103067f7bb9d5836c651b3bb0";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."markupsafe"
      ];
      meta = with lib; {
        homepage = "https://palletsprojects.com/p/jinja/";
        license = licenses.bsdOriginal;
        description = "A very fast and expressive template engine.";
      };
    };

    "lndgrpc" = python.mkDerivation {
      name = "lndgrpc-0.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/18/18/148423007703b44015d97b403680b8ad6433ca63e8b14d99fada76c5bc78/lndgrpc-0.2.0.tar.gz";
        sha256 = "4ef3687b9f43d2307e8356eea9641b2f86124a8a301dec1807af7e7e4443a537";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."aiogrpc"
        self."googleapis-common-protos"
        self."grpcio"
        self."grpcio-tools"
      ];
      meta = with lib; {
        homepage = "https://github.com/adrienemery/lnd-grpc-client";
        license = licenses.mit;
        description = "An rpc client for LND (lightning network deamon)";
      };
    };

    "lnurl" = python.mkDerivation {
      name = "lnurl-0.3.5";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/aa/1a/7f48ab5795bb015e5edd23c01c8a846e1407b7fc72d5ea1ab9031465cb2f/lnurl-0.3.5.tar.gz";
        sha256 = "aaff8552cd4c02f8ae30c82dd3ebe6c6c3a8e06cbc59991281534ba0bbe12890";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."bech32"
        self."pydantic"
      ];
      meta = with lib; {
        homepage = "https://github.com/python-ln/lnurl";
        license = licenses.mit;
        description = "LNURL implementation for Python.";
      };
    };

    "markupsafe" = python.mkDerivation {
      name = "markupsafe-1.1.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz";
        sha256 = "29872e92839765e546828bb7754a68c418d927cd064fd4708fab9fe9c8bb116b";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://palletsprojects.com/p/markupsafe/";
        license = licenses.bsdOriginal;
        description = "Safely add untrusted strings to HTML/XML markup.";
      };
    };

    "marshmallow" = python.mkDerivation {
      name = "marshmallow-3.9.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ea/ac/dc6ed04439ddfb58414a0587cfaa0a2f36b53caf8fadc41b3b4211647434/marshmallow-3.9.1.tar.gz";
        sha256 = "73facc37462dfc0b27f571bdaffbef7709e19f7a616beb3802ea425b07843f4e";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/marshmallow-code/marshmallow";
        license = licenses.mit;
        description = "A lightweight library for converting complex datatypes to and from native Python datatypes.";
      };
    };

    "outcome" = python.mkDerivation {
      name = "outcome-1.1.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/88/b5/9ccedd89d641dcfa5771f636a8a2e99f9d98b09f511f4f870d382ef2b007/outcome-1.1.0.tar.gz";
        sha256 = "e862f01d4e626e63e8f92c38d1f8d5546d3f9cce989263c521b2e7990d186967";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."attrs"
      ];
      meta = with lib; {
        homepage = "https://github.com/python-trio/outcome";
        license = licenses.mit;
        description = "Capture the outcome of Python function calls.";
      };
    };

    "priority" = python.mkDerivation {
      name = "priority-1.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ba/96/7d0b024087062418dfe02a68cd6b195399266ac002fb517aad94cc93e076/priority-1.3.0.tar.gz";
        sha256 = "6bc1961a6d7fcacbfc337769f1a382c8e746566aaa365e78047abe9f66b2ffbe";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "http://python-hyper.org/priority/";
        license = licenses.mit;
        description = "A pure-Python implementation of the HTTP/2 priority tree";
      };
    };

    "protobuf" = python.mkDerivation {
      name = "protobuf-3.14.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/12/ba/d6d9f1432663ab5623f761c86be11e7f2f6fb28348612f48fb082d3cfcea/protobuf-3.14.0.tar.gz";
        sha256 = "1d63eb389347293d8915fb47bee0951c7b5dab522a4a60118b9a18f33e21f8ce";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with lib; {
        homepage = "https://developers.google.com/protocol-buffers/";
        license = licenses.bsd3;
        description = "Protocol Buffers";
      };
    };

    "pydantic" = python.mkDerivation {
      name = "pydantic-1.7.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/24/5d/7be779647b54cef0398fe4f7e7da45f083afe7f7b2ee5afa6b4d6a1caf04/pydantic-1.7.2.tar.gz";
        sha256 = "c8200aecbd1fb914e1bd061d71a4d1d79ecb553165296af0c14989b89e90d09b";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/samuelcolvin/pydantic";
        license = licenses.mit;
        description = "Data validation and settings management using python 3.6 type hinting";
      };
    };

    "pyscss" = python.mkDerivation {
      name = "pyscss-1.3.7";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/e6/0d/6b52a5211121b870cc0c4c908b689fd460630b01a9e501a534db78e67bad/pyScss-1.3.7.tar.gz";
        sha256 = "f1df571569021a23941a538eb154405dde80bed35dc1ea7c5f3e18e0144746bf";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with lib; {
        homepage = "http://github.com/Kronuz/pyScss";
        license = licenses.mit;
        description = "pyScss, a Scss compiler for Python";
      };
    };

    "python-dotenv" = python.mkDerivation {
      name = "python-dotenv-0.15.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/53/04/1a8126516c8febfeb2015844edee977c9b783bdff9b3bcd89b1cc2e1f372/python-dotenv-0.15.0.tar.gz";
        sha256 = "587825ed60b1711daea4832cf37524dfd404325b7db5e25ebe88c495c9f807a0";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/theskumar/python-dotenv";
        license = licenses.bsdOriginal;
        description = "Add .env support to your django/flask apps in development and deployments";
      };
    };

    "quart" = python.mkDerivation {
      name = "quart-0.13.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/3a/fd/093934cd35904422cfd690613f5b5d69b9ddfd799f9b6734cfafd5a08a01/Quart-0.13.1.tar.gz";
        sha256 = "9c634e4c1e4b21b824003c676de1583581258c72b0ac4d2ba747db846e97ff56";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
        self."wheel"
      ];
      propagatedBuildInputs = [
        self."aiofiles"
        self."blinker"
        self."click"
        self."hypercorn"
        self."itsdangerous"
        self."jinja2"
        self."toml"
        self."werkzeug"
      ];
      meta = with lib; {
        homepage = "https://gitlab.com/pgjones/quart/";
        license = licenses.mit;
        description = "A Python ASGI web microframework with the same API as Flask";
      };
    };

    "quart-compress" = python.mkDerivation {
      name = "quart-compress-0.2.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/02/fc/c891471c10f9a7789c0b4a1cdb7c6cf10abfc801772ed0bdf4b19df0afbd/quart-compress-0.2.1.tar.gz";
        sha256 = "63af5e6370aa7850fb219d22e1db89965aeb13b8f27bc83e7f9a44118faa3c54";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."brotli"
        self."quart"
      ];
      meta = with lib; {
        homepage = "https://github.com/AceFire6/quart-compress";
        license = licenses.mit;
        description = "Compress responses in your Quart app with gzip or brotli.";
      };
    };

    "quart-cors" = python.mkDerivation {
      name = "quart-cors-0.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/0e/b7/0b404b025c58d05a8e6efa42205fb3428bc42e68ecf8b95f57e3d26c0917/Quart-CORS-0.3.0.tar.gz";
        sha256 = "c08bdb326219b6c186d19ed6a97a7fd02de8fe36c7856af889494c69b525c53c";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
        self."wheel"
      ];
      propagatedBuildInputs = [
        self."quart"
      ];
      meta = with lib; {
        homepage = "https://gitlab.com/pgjones/quart-cors/";
        license = licenses.mit;
        description = "A Quart extension to provide Cross Origin Resource Sharing, access control, support.";
      };
    };

    "quart-trio" = python.mkDerivation {
      name = "quart-trio-0.6.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/10/75/9538d61f24d767d8be69943cea6e05bc99f44d8bdf570a06298eb927ee26/Quart-Trio-0.6.0.tar.gz";
        sha256 = "8262e82d01ff63a1e74f9a95e5980f9658bfd5facf119d99e11c7bfe23427d69";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
        self."wheel"
      ];
      propagatedBuildInputs = [
        self."hypercorn"
        self."quart"
        self."trio"
      ];
      meta = with lib; {
        homepage = "https://gitlab.com/pgjones/quart-trio/";
        license = licenses.mit;
        description = "A Quart extension to provide trio support.";
      };
    };

    "represent" = python.mkDerivation {
      name = "represent-1.6.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/92/26/6c0a3c6c6806266c9ed1d11d198c64786d76cce67cb482b7985cd787af02/Represent-1.6.0.tar.gz";
        sha256 = "293dfec8b2e9e2150a21a49bfec2cd009ecb600c8c04f9186d2ad222c3cef78a";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with lib; {
        homepage = "https://github.com/RazerM/represent";
        license = licenses.mit;
        description = "Create __repr__ automatically or declaratively.";
      };
    };

    "rfc3986" = python.mkDerivation {
      name = "rfc3986-1.4.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/70/e2/1344681ad04a0971e8884b9a9856e5a13cc4824d15c047f8b0bbcc0b2029/rfc3986-1.4.0.tar.gz";
        sha256 = "112398da31a3344dc25dbf477d8df6cb34f9278a94fee2625d89e4514be8bb9d";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "http://rfc3986.readthedocs.io";
        license = licenses.asl20;
        description = "Validating URI References per RFC 3986";
      };
    };

    "secure" = python.mkDerivation {
      name = "secure-0.2.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/8c/ce/d809b79258afb4845c2935c3ccbfe58ec9c583718bcd10e9c549d71679e9/secure-0.2.1.tar.gz";
        sha256 = "4dc8dd4b548831c3ad7f94079332c41d67c781eccc32215ff5a8a49582c1a447";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/cakinney/secure.py";
        license = licenses.mit;
        description = "A lightweight package that adds optional security headers and cookie attributes for Python web frameworks.";
      };
    };

    "setuptools" = python.mkDerivation {
      name = "setuptools-51.3.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/96/66/1138b7ec901e86139c07900ce906c2f1e5c3400ee1cfd1e7ab3c776248c9/setuptools-51.3.3.tar.gz";
        sha256 = "127ec775c4772bfaf2050557b00c4be6e019e52dc2e171a3fb1cd474783a2497";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/pypa/setuptools";
        license = licenses.mit;
        description = "Easily download, build, install, upgrade, and uninstall Python packages";
      };
    };

    "shortuuid" = python.mkDerivation {
      name = "shortuuid-1.0.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/6f/e0/a881ca1332e9195acb4c2b912d58a4278f6950e118b628188e2bc8830589/shortuuid-1.0.1.tar.gz";
        sha256 = "3c11d2007b915c43bee3e10625f068d8a349e04f0d81f08f5fa08507427ebf1f";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/stochastic-technologies/shortuuid/";
        license = licenses.bsdOriginal;
        description = "A generator library for concise, unambiguous and URL-safe UUIDs.";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.15.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz";
        sha256 = "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/benjaminp/six";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "sniffio" = python.mkDerivation {
      name = "sniffio-1.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/a6/ae/44ed7978bcb1f6337a3e2bef19c941de750d73243fc9389140d62853b686/sniffio-1.2.0.tar.gz";
        sha256 = "c4666eecec1d3f50960c6bdf61ab7bc350648da6c126e3cf6898d8cd4ddcd3de";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python-trio/sniffio";
        license = licenses.mit;
        description = "Sniff out which async library your code is running under";
      };
    };

    "sortedcontainers" = python.mkDerivation {
      name = "sortedcontainers-2.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/14/10/6a9481890bae97da9edd6e737c9c3dec6aea3fc2fa53b0934037b35c89ea/sortedcontainers-2.3.0.tar.gz";
        sha256 = "59cc937650cf60d677c16775597c89a960658a09cf7c1a668f86e1e4464b10a1";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "http://www.grantjenks.com/docs/sortedcontainers/";
        license = licenses.asl20;
        description = "Sorted Containers -- Sorted List, Sorted Dict, Sorted Set";
      };
    };

    "sqlalchemy" = python.mkDerivation {
      name = "sqlalchemy-1.3.20";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/69/ef/6d18860e18db68b8f25e0d268635f2f8cefa7a1cbf6d9d9f90214555a364/SQLAlchemy-1.3.20.tar.gz";
        sha256 = "d2f25c7f410338d31666d7ddedfa67570900e248b940d186b48461bd4e5569a1";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "http://www.sqlalchemy.org";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };

    "sqlalchemy-aio" = python.mkDerivation {
      name = "sqlalchemy-aio-0.16.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/35/76/0ab833ee9c6e2b1b05b312699b4998b5250dd07dd2b69661d766aaf7a79e/sqlalchemy_aio-0.16.0.tar.gz";
        sha256 = "7f77366f55d34891c87386dd0962a28b948b684e8ea5edb7daae4187c0b291bf";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."outcome"
        self."represent"
        self."sqlalchemy"
      ];
      meta = with lib; {
        homepage = "https://github.com/RazerM/sqlalchemy_aio";
        license = licenses.mit;
        description = "Async support for SQLAlchemy.";
      };
    };

    "toml" = python.mkDerivation {
      name = "toml-0.10.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz";
        sha256 = "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/uiri/toml";
        license = licenses.mit;
        description = "Python Library for Tom's Obvious, Minimal Language";
      };
    };

    "trio" = python.mkDerivation {
      name = "trio-0.16.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/e3/c2/1bd1faf18bf74b04691a3f44974a2df958b63874c63024621421fc998511/trio-0.16.0.tar.gz";
        sha256 = "df067dd0560c321af39d412cd81fc3a7d13f55af9150527daab980683e9fcf3c";
      };
      doCheck = commonDoCheck;
      format = "pyproject";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."async-generator"
        self."attrs"
        self."idna"
        self."outcome"
        self."sniffio"
        self."sortedcontainers"
      ];
      meta = with lib; {
        homepage = "https://github.com/python-trio/trio";
        license = licenses.mit;
        description = "A friendly Python library for async concurrency and I/O";
      };
    };

    "typing-extensions" = python.mkDerivation {
      name = "typing-extensions-3.7.4.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/16/06/0f7367eafb692f73158e5c5cbca1aec798cdf78be5167f6415dd4205fa32/typing_extensions-3.7.4.3.tar.gz";
        sha256 = "99d4073b617d30288f569d3f13d2bd7548c3a7e4c8de87db09a9d29bb3a4a60c";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/python/typing/blob/master/typing_extensions/README.rst";
        license = licenses.psfl;
        description = "Backported and Experimental Type Hints for Python 3.5+";
      };
    };

    "werkzeug" = python.mkDerivation {
      name = "werkzeug-1.0.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/10/27/a33329150147594eff0ea4c33c2036c0eadd933141055be0ff911f7f8d04/Werkzeug-1.0.1.tar.gz";
        sha256 = "6c80b1e5ad3665290ea39320b91e1be1e0d5f60652b964a3070216de83d2e47c";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://palletsprojects.com/p/werkzeug/";
        license = licenses.bsdOriginal;
        description = "The comprehensive WSGI web application library.";
      };
    };

    "wheel" = python.mkDerivation {
      name = "wheel-0.36.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ed/46/e298a50dde405e1c202e316fa6a3015ff9288423661d7ea5e8f22f589071/wheel-0.36.2.tar.gz";
        sha256 = "e11eefd162658ea59a60a0f6c7d493a7190ea4b9a85e335b33489d9f17e0245e";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [
        self."setuptools"
      ];
      propagatedBuildInputs = [ ];
      meta = with lib; {
        homepage = "https://github.com/pypa/wheel";
        license = licenses.mit;
        description = "A built-package format for Python";
      };
    };

    "wsproto" = python.mkDerivation {
      name = "wsproto-1.0.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/2b/a4/aded0882f8f1cddd68dcd531309a15bf976f301e6a3554055cc06213c227/wsproto-1.0.0.tar.gz";
        sha256 = "868776f8456997ad0d9720f7322b746bbe9193751b5b290b7f924659377c8c38";
      };
      doCheck = commonDoCheck;
      format = "setuptools";
      buildInputs = commonBuildInputs ++ [

      ];
      propagatedBuildInputs = [
        self."h11"
      ];
      meta = with lib; {
        homepage = "https://github.com/python-hyper/wsproto/";
        license = licenses.mit;
        description = "WebSockets state-machine based protocol implementation";
      };
    };
  };
  localOverridesFile = ./requirements_override.nix;
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
    (
      let src = pkgs.fetchFromGitHub { owner = "nix-community"; repo = "pypi2nix-overrides"; rev = "90e891e83ffd9e55917c48d24624454620d112f0"; sha256 = "0cl1r3sxibgn1ks9xyf5n3rdawq4hlcw4n6xfhg3s1kknz54jp9y"; }; in import "${src}/overrides.nix" { inherit pkgs python; }
    )
  ];
  paramOverrides = [
    (overrides { inherit pkgs python; })
  ];
  allOverrides =
    (
      if (builtins.pathExists localOverridesFile)
      then [ localOverrides ] else [ ]
    ) ++ commonOverrides ++ paramOverrides;

in
python.withPackages (fix' (pkgs.lib.fold
  extends
  generated
  allOverrides
)
)
