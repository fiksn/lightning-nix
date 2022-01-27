{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lnd;
  opensslConf = builtins.toFile "openssl.cnf" (pkgs.lib.readFile ./config/openssl.cnf);
  configFile = pkgs.writeText "lnd.conf" ''
    datadir=${cfg.dataDir}
    logdir=${cfg.dataDir}/logs
    bitcoin.mainnet=1
    tlscertpath=${cfg.certFile}
    tlskeypath=${cfg.keyFile}

    bitcoin.active=1
    bitcoin.node=bitcoind

    protocol.wumbo-channels=true
    accept-keysend=true
    accept-amp=true

    ${cfg.extraConfig}
  '';
  init-lnd-wallet-script = pkgs.writeScript "init-lnd-wallet.sh" ''
    #!/bin/sh

    set -e
    umask 377

    # Have some timeout
    while ! ${pkgs.libressl.nc}/bin/nc -z 127.0.0.1 8080; do
      ${pkgs.coreutils}/bin/sleep 1
    done

    if [ ! -f ${cfg.dataDir}/secrets/lnd-seed-mnemonic ]
    then
      ${pkgs.coreutils}/bin/echo Creating lnd seed

      ${pkgs.curl}/bin/curl -s \
      --cacert ${cfg.certFile} \
      -X GET https://127.0.0.1:8080/v1/genseed | ${pkgs.jq}/bin/jq -c '.cipher_seed_mnemonic' > ${cfg.dataDir}/secrets/lnd-seed-mnemonic
    fi

    if [ ! -f ${cfg.dataDir}/chain/bitcoin/mainnet/wallet.db ]
    then
      ${pkgs.coreutils}/bin/echo Creating lnd wallet

      ${pkgs.curl}/bin/curl -s \
      --cacert ${cfg.certFile} \
      -X POST -d "{\"wallet_password\": \"$(${pkgs.coreutils}/bin/cat ${cfg.dataDir}/secrets/lnd-wallet-password | ${pkgs.coreutils}/bin/tr -d '\n' | ${pkgs.coreutils}/bin/base64 -w0)\", \
      \"cipher_seed_mnemonic\": $(${pkgs.coreutils}/bin/cat ${cfg.dataDir}/secrets/lnd-seed-mnemonic | ${pkgs.coreutils}/bin/tr -d '\n')}" \
      https://127.0.0.1:8080/v1/initwallet
    else
      ${pkgs.coreutils}/bin/echo Unlocking lnd wallet

      ${pkgs.curl}/bin/curl -s \
          -H "Grpc-Metadata-macaroon: $(${pkgs.xxd}/bin/xxd -ps -u -c 99999 ${cfg.dataDir}/chain/bitcoin/mainnet/admin.macaroon)" \
          -k \
          -X POST \
          -d "{\"wallet_password\": \"$(${pkgs.coreutils}/bin/cat ${cfg.dataDir}/secrets/lnd-wallet-password | ${pkgs.coreutils}/bin/tr -d '\n' | ${pkgs.coreutils}/bin/base64 -w0)\"}" \
          https://127.0.0.1:8080/v1/unlockwallet
    fi

    exit 0
  '';
in
{

  options.services.lnd = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the LND service will be installed.
      '';
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/lnd";
      description = "The data directory for LND.";
    };
    certFile = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/secrets/lnd.cert";
      description = "Certificate file.";
    };
    keyFile = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/secrets/lnd.key";
      description = "Key file.";
    };
    user = mkOption {
      type = types.str;
      default = "lnd";
      description = "The user as which to run LND.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run LND.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        autopilot.active=1
      '';
      description = "Additional configurations to be appended to <filename>lnd.conf</filename>.";
    };
    extraConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Extra configuration file if applicable";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      description = "LND daemon user";
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    systemd.services.lnd = {
      description = "Run LND";
      path = [ pkgs.lnd ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "bitcoind-default.service" ];
      after = [ "bitcoind-default.service" ];
      preStart = lib.mkAfter ''
        ${pkgs.coreutils}/bin/mkdir -m 0770 -p ${cfg.dataDir}/secrets
        ${pkgs.coreutils}/bin/cp ${configFile} ${cfg.dataDir}/lnd.conf
        ${optionalString (cfg.extraConfigFile != null) "${pkgs.coreutils}/bin/cat ${cfg.extraConfigFile} >> ${cfg.dataDir}/lnd.conf" }
        ${pkgs.coreutils}/bin/chmod u=rw,g=r,o= ${cfg.dataDir}/lnd.conf

        if [ ! -e ${cfg.dataDir}/secrets/lnd-wallet-password ]; then
          PASS=$(${pkgs.coreutils}/bin/tr -dc A-Za-z0-9_ < /dev/urandom | ${pkgs.coreutils}/bin/head -c 16 | ${pkgs.findutils}/bin/xargs)
          ${pkgs.coreutils}/bin/echo $PASS > ${cfg.dataDir}/secrets/lnd-wallet-password
        fi
 
        #if [ ! -e ${cfg.keyFile} ] || [ ! -e ${cfg.certFile} ]; then
        #  ${pkgs.coreutils}/bin/echo Generate LND compatible TLS Cert
        #  ${pkgs.openssl}/bin/openssl ecparam -genkey -name prime256v1 -out ${cfg.keyFile}
        #  ${pkgs.openssl}/bin/openssl req -config ${opensslConf} -new -sha256 -key ${cfg.keyFile} -out ${cfg.dataDir}/secrets/lnd.csr -subj '/CN=localhost/O=lnd'
        #  ${pkgs.openssl}/bin/openssl req -config ${opensslConf} -x509 -sha256 -days 1825 -key ${cfg.keyFile} -in ${cfg.dataDir}/secrets/lnd.csr -out ${cfg.certFile}
        #  ${pkgs.coreutils}/bin/rm ${cfg.dataDir}/secrets/lnd.csr
        #  ${pkgs.coreutils}/bin/echo Done
        #else
        #  ${pkgs.coreutils}/bin/echo LND cert already exists. Skipping
        #fi

        ${pkgs.coreutils}/bin/chown -R '${cfg.user}:${cfg.group}' '${cfg.dataDir}'
      '';
      serviceConfig = {
        PermissionsStartOnly = "true";
        ExecStart = "${pkgs.lnd}/bin/lnd --configfile=${cfg.dataDir}/lnd.conf";
        ExecStartPost = "${pkgs.bash}/bin/bash ${init-lnd-wallet-script}";
        User = "${cfg.user}";
        Restart = "on-failure";
        RestartSec = "10min";
        TimeoutSec = "10min";
        TimeoutStartSec = "600";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };
    };

    environment.interactiveShellInit = ''
      alias lncli='lncli --macaroonpath ${config.services.lnd.dataDir}/chain/bitcoin/mainnet/admin.macaroon --tlscertpath ${config.services.lnd.certFile}'
      alias lndconnect='lndconnect --configfile=${cfg.dataDir}/lnd.conf'
    '';

    environment.systemPackages = with pkgs; [ lndconnect ];

  };
}
