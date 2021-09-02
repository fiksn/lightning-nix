{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.btcpayserver;
  empty = { switch = ""; url = null; pkg = null; };
  cases = { "postgresql" = { switch = "--postgres"; url = "Host=/run/postgresql;Port=5432;Database=btcpayserver"; pkg = pkgs.postgresql; }; "mysql" = { switch = "--mysql"; url = "Host=/run/mysqld/mysqld.sock;User=btcpayserver;Port=3306;Database=btcpayserver"; pkg = pkgs.mysql80; }; "sqlite" = empty; };
  lookup = attrs: key: attrs."${key}";
  containsLocalhost = str: lib.hasInfix "127.0.0.1" str || lib.hasInfix "localhost" str || lib.hasInfix "/" str;
  deps = (if (cfg.manageDatabase && cfg.database == "postgresql") then [ "postgresql.service" ] else [ ])
    ++
    (if (cfg.manageDatabase && cfg.database == "mysql") then [ "mysql.service" ] else [ ]);
in
{
  options.services.btcpayserver = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable BTCPayServer
      '';
    };

    user = mkOption {
      type = types.str;
      default = "btcpayserver";
      description = "The user as which to run BTCPayServer.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run BTCPayServer.";
    };

    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind IP";
    };

    port = mkOption {
      type = types.port;
      default = 3002;
      description = "Bind port";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory";
    };

    database = mkOption {
      type = with types; enum [ "postgresql" "mysql" "sqlite" ];
      default = "postgresql";
      description = "Which database to use postgresql, mysql or sqlite (only postgresql is officially supported)";
    };

    databaseUrl = mkOption {
      type = types.nullOr types.str;
      default = (lookup cases cfg.database).url;
      description = "URL of database server";
    };

    databaseUrlFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File with URL of database server";
      example = "/run/keys/db-url";
    };

    manageDatabase = mkOption {
      type = types.bool;
      default = if (containsLocalhost cfg.databaseUrl && cfg.database != "sqlite") then true else false;
      description = "Should we manage the database (install & create correct tables)";
    };

    databasePkg = mkOption {
      type = types.nullOr types.package;
      default = (lookup cases cfg.database).pkg;
      description = "Database package";
    };

    extraCmdLineOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra command line options to pass to BTCPayServer
        Run BTCPayServer --help to list all available options.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.manageDatabase -> cfg.databasePkg != null;
        message = "If you want to manageDatabase databasePkg must be set";
      }
      {
        assertion = cfg.database == "sqlite" -> (!cfg.manageDatabase && cfg.databasePkg == null && cfg.databaseUrl == null && cfg.databaseUrlFile == null);
        message = "You shall not configure manageDatabase / databasePkg / databaseUrl / databaseUrlFile when using sqlite";
      }
      {
        assertion = cfg.database != "sqlite" -> ((cfg.databaseUrl != null && cfg.databaseUrlFile == null) || (cfg.databaseUrl == null && cfg.databaseUrlFile != null));
        message = "Options databaseUrl and databaseUrlFile are mutually exclusive, but one of them needs to be set";
      }
    ];

    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    environment.systemPackages = with pkgs; [ btcpayserver ];

    services.mysql = mkIf (cfg.manageDatabase && cfg.database == "mysql") {
      enable = true;
      package = cfg.databasePkg;
      ensureDatabases = [ "btcpayserver" ];
      ensureUsers = [
        {
          name = "btcpayserver";
          ensurePermissions = {
            "btcpayserver.*" = "ALL PRIVILEGES";
            "*.*" = "SELECT, LOCK TABLES";
          };
        }
      ];
    };

    services.postgresql = mkIf (cfg.manageDatabase && cfg.database == "postgresql") {
      enable = true;
      package = cfg.databasePkg;
      ensureDatabases = [ "btcpayserver" ];
      ensureUsers = [
        {
          name = "btcpayserver";
          ensurePermissions = {
            # "btcpayserver" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    systemd.services.btcpayserver = {
      description = "BTCPayServer";
      wantedBy = [ "multi-user.target" ];
      requires = deps;
      after = deps;
      script = optionalString (cfg.databaseUrlFile != null) ''
        DATABASE_URL=$(${pkgs.coreutils}/bin/cat ${cfg.databaseUrlFile})
      '' +
      optionalString (cfg.databaseUrl != null) ''
        DATABASE_URL="${cfg.databaseUrl}"
      '' +
      ''
        ${pkgs.btcpayserver}/bin/btcpayserver -d ${cfg.dataDir} -b ${cfg.bind} -p ${toString cfg.port} ${(lookup cases cfg.database).switch} $DATABASE_URL ${toString cfg.extraCmdLineOptions};
      '';

      serviceConfig = {
        # the stuff wants to write to ~/.btcpayserver
        Environment = "\"HOME=${cfg.dataDir}\"";
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
        #MemoryDenyWriteExecute = "true";
      };
    };
  };
}
