{ buildGoModule
, fetchFromGitHub
, lib
, go-rice
}:
buildGoModule rec {
  pname = "lnme";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "bumi";
    repo = "lnme";
    rev = "${version}";
    sha256 = "1g5z2n5pak29km5igr85mv2d5bbaa2r393jxmwg2ijbh30d13pxw";
  };

  vendorSha256 = "07qnzl5f0g2pjgx90qym9a5lgkb8m000k8313daibq6kbzgwy5k9";
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
