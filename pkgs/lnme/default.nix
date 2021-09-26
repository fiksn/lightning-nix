{ buildGoModule
, fetchFromGitHub
, lib
, go-rice
}:
buildGoModule rec {
  pname = "lnme";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bumi";
    repo = "lnme";
    rev = "${version}";
    sha256 = "0gnjfzjg7hvrf9x7xl0r72r7m8fjayxlry0lyad6346nzrs5k5w2";
  };

  vendorSha256 = "0g9k62cq78kb1yvnmhr4icjsxvjp4b6i5yxlblbl4201g2hjrshn";
  preBuild = ''
    rice embed-go
  '';

  nativeBuildInputs = [ go-rice ];

  meta = with lib; {
    description = "LnMe - your friendly lighting payment page";
    homepage = "https://github.com/bumi/lnme";
    license = licenses.mit;
  };
}
