{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "satdress";
  version = "0.4.0-git";

  src = fetchFromGitHub {
    owner = "fiatjaf";
    repo = "satdress";
    rev = "d49f2dc2c5e2cde3de6348796dfd7dbc8e1fb000";
    sha256 = "1g67bssq1561nx2lk4ww1pgvnysy6wa4hwnzc89da3l98vcmjg83";
  };

  vendorSha256 = "1pqrr91kwi673iifn21igj9m3bwk36qxppnynl9l3qjv2k01dxw4";

  meta = with lib; {
    description = "Federated Lightning addresses server";
    homepage = "https://github.com/fiatjaf/satdress";
    license = licenses.mit;
  };
}
