{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lnme;
in
{
  options.services.lnme = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable LnMe
      '';
    };

    user = mkOption {
      type = types.str;
      default = "lnme";
      description = "The user as which to run LnMe.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run LnMe.";
    };

    listenPort = mkOption {
      type = types.port;
      default = 1323;
      description = "Listen port";
    };

    macaroonPath = mkOption {
      type = types.path;
      description = "Macaroon path";
    };

    certPath = mkOption {
      type = types.path;
      description = "Cert path";
    };

    lndUrl = mkOption {
      type = types.str;
      default = "127.0.0.1:10009";
      description = "Host and port of LND";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory";
    };

    disableCors = mkOption {
      type = types.bool;
      default = false;
      description = "Disable CORS headers";
    };

    disableLnAddress = mkOption {
      type = types.bool;
      default = false;
      description = "Disable Lightning Address handling";
    };

    disableWebsite = mkOption {
      type = types.bool;
      default = false;
      description = "Disable default embedded website";
    };

    requestLimit = mkOption {
      type = types.int;
      default = 5;
      description = "Request limit per second";
    };

    useStaticPath = mkOption {
      type = types.bool;
      default = false;
      description = "Use static assets directory";
    };

    staticPath = mkOption {
      type = types.path;
      default = cfg.dataDir;
      description = "Path to a static assets directory";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    environment.systemPackages = with pkgs; [ lnme ];

    systemd.services.lnme = {
      description = "Run LnMe";
      path = [ pkgs.lnme ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.dataDir}
        chown ${cfg.user}:${cfg.group} ${cfg.dataDir}
        chmod 750 ${cfg.dataDir}
      '';
      serviceConfig = {
        PermissionsStartOnly = "true";
        ExecStart = ''
          ${pkgs.lnme}/bin/lnme
          -lnd-address ${cfg.lndUrl}
          -lnd-cert-path ${cfg.certPath}
          -lnd-macaroon-path ${cfg.macaroonPath}
          -port ${toString cfg.listenPort}
          -request-limit ${toString cfg.requestLimit}
          ${optionalString cfg.useStaticPath "-static-path ${cfg.staticPath}"}
          ${optionalString cfg.disableCors "-disable-cors"}
          ${optionalString cfg.disableLnAddress "-disable-ln-address"}
          ${optionalString cfg.disableWebsite "-disable-website"}
        '';
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Restart = "always";
        RestartSec = "30s";
        TimeoutSec = "5min";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };
    };
  };
}
