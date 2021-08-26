{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "aperture";
  version = "v0.1-beta";

  # nix-prefetch-github "lightninglabs" "aperture" --rev "v0.1-beta" | jq -r .sha256
  src = fetchFromGitHub {
    owner = "lightninglabs";
    repo = "aperture";
    rev = "v0.1-beta";
    sha256 = "10inj9zs3izvl9i8x7p7dqzgpcq789578pnkmsc9vp859rjq4nk2";
  };

  vendorSha256 = "1fcs767fbcvwpa34jlkmk8rmw9k5dfaqa5f918mzh2100863s8az";

  meta = with lib; {
    description = "Lightning Service Authentication Token (LSAT) proxy";
    homepage = "https://github.com/lightninglabs/aperture";
    license = lib.licenses.mit;
  };
}
