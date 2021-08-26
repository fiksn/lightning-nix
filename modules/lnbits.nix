{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lnbits;
  env = {
    QUART_APP = "lnbits.app:create_app()";
    QUART_ENV = "production";
    QUART_DEBUG = "false";
    HOST = "${cfg.listenHost}";
    PORT = "${toString cfg.listenPort}";
    LNBITS_DATA_FOLDER = "${cfg.dataDir}/lnbits/data";
  } // cfg.extraEnv;
in
{
  options.services.lnbits = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the lnbits service will be installed.
      '';
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/lnbits";
      description = "The data directory for lnbits.";
    };
    user = mkOption {
      type = types.str;
      default = "lnd";
      description = "The user as which to run lnbits.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run lnbits.";
    };
    listenHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen host";
    };
    listenPort = mkOption {
      type = types.port;
      default = 3000;
      description = "Listen port";
    };
    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables.";
    };
    extraScript = mkOption {
      type = types.str;
      default = "";
      description = "Extra script.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      description = "lnbits daemon user";
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    systemd.services.lnbits = {
      description = "Run lnbits";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.lnbits ];
      environment = env;

      preStart = ''
        cp -rf ${pkgs.lnbits}/lnbits ${cfg.dataDir}
        quart assets
        quart migrate

        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}/lnbits/data
        chmod u+w,g+w ${cfg.dataDir}/lnbits/data
      '';

      script = cfg.extraScript + ''
        ${pkgs.lnbits}/bin/hypercorn -k trio --bind ${cfg.listenHost}:${toString cfg.listenPort} 'lnbits.app:create_app()'
      '';
      serviceConfig = {
        PermissionsStartOnly = "true";
        WorkingDirectory = cfg.dataDir;

        User = cfg.user;
        Restart = "on-failure";
        RestartSec = "5min";
        TimeoutSec = "5min";
        TimeoutStartSec = "60";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };
    };

    environment.systemPackages = with pkgs; [ lnbits ];
  };
}
