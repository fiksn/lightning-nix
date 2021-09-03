{ config, pkgs, lib, self, ... }:
let
  nbxplorerData = "/storage/nbxplorer";
  btcpayserverData = "/storage/btcpayserver";
  listen = "127.0.0.1";
  nbxplorerPort = 24444;
  btcpayPort = 3002;
  user = "btcpayserver";
  myname = "btcpayserver";
  # Full node
  server = "1.2.3.4";
in
{
  imports = [
    ../profiles/common.nix
  ] ++ lib.attrValues self.nixosModules;

  # Change me
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts."${myname}" = {
      forceSSL = true;
      default = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${listen}:${toString btcpayPort}";
        proxyWebsockets = true;
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
        ;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    email = "1640719+fiksn@users.noreply.github.com";
  };

  services.nbxplorer = {
    enable = true;
    dataDir = "${nbxplorerData}";
    user = user;
    bind = "${listen}";
    port = nbxplorerPort;
    btcRpcAuthFile = "${btcpayserverData}/btcrpcauth";
    extraCmdLineOptions = [ "--btcrpcurl http://${server}:8332" "--btcnodeendpoint ${server}:8333" ];
  };

  services.btcpayserver = {
    enable = true;
    database = "postgresql";
    dataDir = "${btcpayserverData}";
    bind = "${listen}";
    port = btcpayPort;
    user = user;
    # TODO: Automate this
    # [root@ln:/storage/lnd/data/secrets]# openssl x509 -noout -fingerprint -sha256 -inform pem -in ./lnd.cert | cut -d"=" -f 2 | tr -d ':' | tr '[:upper:]' '[:lower:]'
    # XXX

    extraCmdLineOptions = [ "--btcexplorerurl http://${listen}:${toString nbxplorerPort}" "--btcexplorercookiefile ${nbxplorerData}/Main/.cookie" "--btclightning 'type=lnd-rest;server=https://${server}:8080;macaroonfilepath=${btcpayserverData}/invoice.macaroon;certthumbprint=XXX'" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
