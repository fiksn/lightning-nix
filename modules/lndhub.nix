{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lndhub;
  workDir = "/tmp";
  configFile = pkgs.writeText "lndhub.conf" ''
    {
      "bitcoind": {
        "rpc": "http://%RPC_USER%:%RPC_PASS%@127.0.0.1:8332"
      },
      "redis": {
        "port": 6379,
        "host": "127.0.0.1",
        "family": 4,
        "password": "%REDIS_PASS%",
        "db": 0
      },
      "lnd": {
        "url": "127.0.0.1:10009"
      }

      ${cfg.extraConfig}
    }
  '';
in
{
  options.services.lndhub = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the LndHub service will be installed.
      '';
    };
    redisPassFile = mkOption {
      type = types.path;
      description = "Location of redis password file";
    };
    tlsCert = mkOption {
      type = types.path;
      description = "Location of LND cert";
    };
    macaroon = mkOption {
      type = types.path;
      description = "Location of admin macaroon";
    };
    bitcoinRpcUser = mkOption {
      type = types.str;
      default = "lndhub";
      description = "The user as which to connect to bitcoind";
    };
    bitcoinRpcPassFile = mkOption {
      type = types.path;
      description = "The file with password for bitcoind";
    };
    user = mkOption {
      type = types.str;
      default = "lndhub";
      description = "The user as which to run LndHub.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run LndHub.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        autopilot.active=1
      '';
      description = "Additional configurations to be appended to configuration";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      isSystemUser = true;
    };
    # Currently this is just redis
    users.users.redis.extraGroups = [ "${cfg.group}" ];

    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    services.redis.servers."" = {
      enable = true;
      requirePassFile = "${cfg.redisPassFile}";
    };

    services.bitcoind."default".extraConfig = ''
      deprecatedrpc=accounts
    '';

    systemd.services.lndhub-credentials = {
      description = "Take care of LndHub credentials";
      wantedBy = [ "multi-user.target" ];
      script = ''
        if [ ! -e ${cfg.redisPassFile} ]; then
          PASS=$(${pkgs.coreutils}/bin/tr -dc "A-Za-z0-9_" < /dev/urandom | ${ pkgs.coreutils}/bin/head -c 16 | ${pkgs.findutils}/bin/xargs)
          ${pkgs.coreutils}/bin/echo $PASS > ${cfg.redisPassFile}
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "${cfg.user}";
        RemainAfterExit = "true";
      };
    };

    systemd.services.lndhub = {
      description = "Run LndHub";
      path = [ pkgs.lndhub ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "lndhub-credentials.service" "bitcoind-default.service" "lnd.service" ];
      after = [ "lndhub-credentials" "bitcoind-default.service" "lnd.service" ];
      environment = {
        PORT = "3001";
      };
      script = ''
        REDIS_PASS=$(${pkgs.coreutils}/bin/cat ${cfg.redisPassFile})
        BITCOIN_PASS=$(${pkgs.coreutils}/bin/cat ${cfg.bitcoinRpcPassFile})
        export CONFIG=$(${pkgs.coreutils}/bin/cat ${configFile} | ${pkgs.gnused}/bin/sed "s/%REDIS_PASS%/$REDIS_PASS/g" | ${pkgs.gnused}/bin/sed "s/%RPC_USER%/${cfg.bitcoinRpcUser}/g" | ${pkgs.gnused}/bin/sed "s/%RPC_PASS%/$BITCOIN_PASS/g")
        export MACAROON=$(${pkgs.xxd}/bin/xxd -ps -u -c 99999 ${cfg.macaroon})
        export TLSCERT=$(${pkgs.xxd}/bin/xxd -ps -u -c 99999 ${cfg.tlsCert})

        # Make sure gRPC .proto files are in working directory
        ${pkgs.coreutils}/bin/cp -f ${pkgs.lndhub}/lib/node_modules/lndhub/build/*.proto ${workDir}
        # And some templates
        ${pkgs.coreutils}/bin/cp -rf ${pkgs.lndhub}/lib/node_modules/lndhub/build/templates/ ${workDir}/
        ${pkgs.coreutils}/bin/cp -rf ${pkgs.lndhub}/lib/node_modules/lndhub/build/static/ ${workDir}/

        # Start
        ${pkgs.nodejs}/bin/node ${pkgs.lndhub}/lib/node_modules/lndhub/build/index.js
      '';

      serviceConfig = {
        PermissionsStartOnly = "true";
        User = "${cfg.user}";
        Restart = "on-failure";
        RestartSec = "30s";
        TimeoutSec = "5min";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        # NodeJS won't work with this
        #MemoryDenyWriteExecute = "true";
        WorkingDirectory = "${workDir}";
      };
    };

    environment.systemPackages = with pkgs; [ lndhub nodejs ];
  };
}
