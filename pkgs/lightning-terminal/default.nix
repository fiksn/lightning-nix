{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "lightning-terminal";
  version = "0.1.0-alpha";

  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "lightning-terminal";
    rev = "v${version}";
    sha256 = "129vi8z2sk4hagk7axa675nba6sbj9km88zlq8a1g8di7v2k9z6a";
  };

  vendorSha256 = "0a4bk2qry0isnrvl0adwikqn6imxwzlaq5j3nglb5rmwwq2cdz0r";

  subPackages = [ "cmd/lncli" "cmd/frcli" "cmd/loop" "cmd/litd" ];

  meta = with lib; {
    description = "Lightning Terminal";
    homepage = "https://github.com/lightningnlabs/lightning-terminal";
    license = lib.licenses.mit;
    maintainers = with maintainers; [ cypherpunk2140 ];
  };
}
