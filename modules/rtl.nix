{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.rtl;
  loggingStr = if cfg.enableLogging then "true" else "false";

  configFile = pkgs.writeText "RTL-Config.json" ''
    {
      "port": "${toString cfg.listenPort}",
      "host": "${cfg.listenHost}",
      "defaultNodeIndex": 1,
      "SSO": {
        "rtlSSO": 0,
        "rtlCookiePath": "",
        "logoutRedirectLink": ""
      },
      "nodes": [
        {
          "index": 1,
          "lnNode": "${cfg.nodeName}",
          "lnImplementation": "LND",
          "Authentication": {
            "macaroonPath": "${cfg.macaroonPath}",
            "configPath": "${cfg.configPath}"
          },
          "Settings": {
            ${cfg.extraSettings},
            "channelBackupPath": "${cfg.channelBackupPath}",
            "enableLogging": "${loggingStr}",
            "lnServerUrl": "${cfg.nodeUrl}"
          }
        }
      ],
      "multiPassHashed": "${cfg.passwordHash}"
    }
  '';
in
{
  options.services.rtl = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Ride the Lightning
      '';
    };

    user = mkOption {
      type = types.str;
      default = "rtl";
      description = "The user as which to run RTL.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run RTL.";
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

    nodeName = mkOption {
      type = types.str;
      default = "node";
      description = "Node name";
    };

    nodeUrl = mkOption {
      type = types.str;
      default = "https://localhost:8080/v1";
      description = "Node name";
    };

    macaroonPath = mkOption {
      type = types.path;
      description = "Macaroon path";
    };

    configPath = mkOption {
      type = types.path;
      description = "LND config path";
    };

    channelBackupPath = mkOption {
      type = types.path;
      default = "/tmp";
      description = "Channel backup path";
    };

    passwordHash = mkOption {
      type = types.str;
      default = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8";
      description = "SHA256 of password";
    };

    enableLogging = mkOption {
      type = types.bool;
      default = false;
      description = "Enable logging";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory";
    };

    extraSettings = mkOption {
      type = types.lines;
      description = "Additional configuration.";
      default = ''
        "userPersona": "OPERATOR",
        "themeMode": "DAY",
        "themeColor": "PURPLE",
        "fiatConversion": true
      '';
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

    environment.systemPackages = with pkgs; [ nodejs rtl ];

    systemd.services.rtl = {
      description = "Run RTL";
      path = [ pkgs.rtl ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "lnd.service" ];
      after = [ "lnd.service" ];
      preStart = ''
        mkdir -p ${cfg.dataDir}
        chown ${cfg.user}:${cfg.group} ${cfg.dataDir}
        chmod 750 ${cfg.dataDir}
        if [ ! -e "${cfg.dataDir}/RTL-Config.json" ]; then
          cp -f ${configFile} ${cfg.dataDir}/RTL-Config.json
          chown ${cfg.user}:${cfg.group} ${cfg.dataDir}/RTL-Config.json
        fi
      '';
      serviceConfig = {
        PermissionsStartOnly = "true";
        Environment = "\"RTL_CONFIG_PATH=${cfg.dataDir}\"";
        ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.rtl}/lib/node_modules/rtl/rtl.js";
        WorkingDirectory = "${cfg.dataDir}";
        User = "${cfg.user}";
        Restart = "always";
        RestartSec = "30s";
        TimeoutSec = "5min";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        # With this enabled node crashses heh
        #MemoryDenyWriteExecute = "true";
      };
    };
  };
}
