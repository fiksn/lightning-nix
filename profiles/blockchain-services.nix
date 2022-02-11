{ config, pkgs, lib, ... }:
let
  prefixLinesWith = string: prefix: builtins.concatStringsSep "\n" (map (x: if x != "" then prefix + x else x) (lib.splitString "\n" string));
  keysGroup = "keys";
  lndBitcoinPrefix = "bitcoind.";
  zmqConfig = ''
    zmqpubrawblock=tcp://127.0.0.1:28332
    zmqpubrawtx=tcp://127.0.0.1:28333
  '';
in
{
  imports = [ ../modules ];

  users = {
    users = {
      bitcoin.isSystemUser = true;
      bitcoin.group = "bitcoin";
      bitcoin.extraGroups = [ keysGroup ];
      lnd.extraGroups = [ keysGroup ];
      lnd.isSystemUser = true;
    };
    groups.bitcoin = {};
  };

  services.bitcoin-secrets = {
    enable = true;

    dataDir = "${config.services.node-storage.mountPath}/secrets";

    user = "keys";
    group = keysGroup;

    services = [ "lnd" "lndhub" ];
  };

  services.bitcoind = {
    "default" = {
      enable = true;

      user = "bitcoin";
      group = "bitcoin";

      dataDir = "${config.services.node-storage.mountPath}/bitcoin/data";
      rpc = {
        port = 8332;
      };

      extraConfig = ''
        txindex=1
        walletdir=${config.services.node-storage.mountPath}/bitcoin/wallet
        rpccookiefile=${config.services.node-storage.mountPath}/bitcoin/data/.cookie
        includeconf=${config.services.bitcoin-secrets.dataDir}/bitcoin-lnd.conf
        includeconf=${config.services.bitcoin-secrets.dataDir}/bitcoin-lndhub.conf
        ${zmqConfig}
      '';
    };
  };

  services.lnd = {
    enable = true;

    user = "lnd";
    group = "lnd";

    dataDir = "${config.services.node-storage.mountPath}/lnd/data";
    extraConfig = prefixLinesWith zmqConfig lndBitcoinPrefix;
    extraConfigFile = "${config.services.lnd.dataDir}/lnd-credentials.conf";
  };

  systemd.services.bitcoind.requires = [ "bitcoin-secrets.service" ];
  systemd.services.bitcoind.after = [ "bitcoin-secrets.service" ];

  systemd.services.lnd.preStart = ''
    ${pkgs.coreutils}/bin/mkdir -m 0770 -p ${config.services.lnd.dataDir}
    ${pkgs.coreutils}/bin/echo -e "${lndBitcoinPrefix}rpcuser=lnd\n${lndBitcoinPrefix}rpcpass=$(${pkgs.coreutils}/bin/cat ${config.services.bitcoin-secrets.dataDir}/lnd-bitcoin-rpc)" > ${config.services.lnd.dataDir}/lnd-credentials.conf
  '';
  systemd.services.lnd.requires = [ "bitcoin-secrets.service" "bitcoind-default.service" ];
  systemd.services.lnd.after = [ "bitcoin-secrets.service" "bitcoind-default.service" ];

  environment.interactiveShellInit = ''
    alias bitcoin-cli='bitcoin-cli -rpccookiefile=${config.services.node-storage.mountPath}/bitcoin/data/.cookie'
  '';

  services.lndhub = {
    enable = true;

    user = "lnd";
    group = "lnd";

    redisPassFile = "${config.services.lnd.dataDir}/redis.pass";
    tlsCert = "${config.services.lnd.certFile}";
    macaroon = "${config.services.lnd.dataDir}/chain/bitcoin/mainnet/admin.macaroon";
    bitcoinRpcUser = "lndhub";
    bitcoinRpcPassFile = "${config.services.bitcoin-secrets.dataDir}/lndhub-bitcoin-rpc";
  };

  services.rtl = {
    enable = true;
    nodeName = "wallsat";
    nodeUrl = "http://127.0.0.1:8080/v1";
    dataDir = "/storage/rtl";

    user = "lnd";
    group = "lnd";

    macaroonPath = "${config.services.lnd.dataDir}/chain/bitcoin/mainnet";
    configPath = "${config.services.lnd.dataDir}/lnd.conf";
    channelBackupPath = "/tmp";
  };
}
