{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "lightning-terminal";
  version = "0.6.1-alpha";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "lightning-terminal";
    rev = "v${version}";
    sha256 = "0434girh41zd15gpwkb721pzjnx2ay02yhwsl46sxaq7yjwnp37b";
  };

  vendorSha256 = "1c9i255csq80ygpsjgl5fh858bwzazynfw98629fvy2nc2blywkl";

  subPackages = [ "cmd/litcli "cmd/litd" ];

  meta = with lib; {
    description = "Lightning Terminal";
    homepage = "https://github.com/lightningnlabs/lightning-terminal";
    license = licenses.mit;
    maintainers = with maintainers; [ proofofkeags prusnak ];
  };
}
