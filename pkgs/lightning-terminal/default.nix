{ buildGoModule
, mkYarnPackage
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "lightning-terminal";
  version = "0.6.2-alpha";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "lightning-terminal";
    rev = "v${version}";
    sha256 = "0v1byxcnj0da64yyql2hb1ylwlfq482nkm2l1bj3l9imbcxgwjcj";
  };

  vendorSha256 = "1l04q7xww4g61ki3zd9cwj62k9q9b5wdn9g3cmj3j3cvk7ncah9h";

  subPackages = [ "cmd/litcli" "cmd/litd" ];

  frontend = let pname = "lightning-terminal"; in mkYarnPackage {
    name = "lightning-terminal-frontend";
    src = "${src}/app";
    packageJSON = "${src}/app/package.json";
    yarnLock = "${src}/app/yarn.lock";

    #doDist = false;
    distPhase = "true";

    installPhase = ''
      runHook preInstall

      # Since the stupid app uses ../node_modules (and relative paths are off)
      sed -i "s|@import '../node_modules/|@import '../../../node_modules/|g" /build/app/deps/lightning-terminal/src/App.scss

      # Stupid .cache folder in node_modules needs to be writable
      shopt -s dotglob
      ORIG=$(readlink /build/app/deps/lightning-terminal/node_modules)
      rm /build/app/deps/lightning-terminal/node_modules
      mkdir /build/app/deps/lightning-terminal/node_modules
      cp -a $ORIG/* /build/app/deps/lightning-terminal/node_modules
      shopt -u dotglob

      # Or else you get even more issues with missing .eslintrc
      export DISABLE_ESLINT_PLUGIN=true

      # The actual build
      yarn --offline build

      mkdir -p $out
      cp -a /build/app/deps/lightning-terminal/build/* $out

      runHook postInstall
    '';
  };

  postPatch = ''
    mkdir -p app/build
    cp -r ${frontend}/* app/build
  '';

  meta = with lib; {
    description = "Lightning Terminal";
    homepage = "https://github.com/lightningnlabs/lightning-terminal";
    license = licenses.mit;
  };

}
