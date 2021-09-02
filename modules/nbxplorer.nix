{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.nbxplorer;
in
{
  options.services.nbxplorer = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable NBXplorer
      '';
    };

    user = mkOption {
      type = types.str;
      default = "btcpayserver";
      description = "The user as which to run NBXplorer.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run NBXplorer.";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory";
    };

    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind IP";
    };

    port = mkOption {
      type = types.port;
      default = 24444;
      description = "Bind port";
    };

    btcRpcAuth = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Authentication string";
    };

    btcRpcAuthFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File with authentication string";
      example = "/run/keys/bitcoin-rpc-auth";
    };

    extraCmdLineOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra command line options to pass to NBXplorer.
        Run NBXplorer --help to list all available options.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.btcRpcAuth != null && cfg.btcRpcAuthFile == null) || (cfg.btcRpcAuth == null && cfg.btcRpcAuthFile != null);
        message = "Options btcRpcAuth and btcRpcAuthFile are mutually exclusive, but one of them needs to be set";
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

    environment.systemPackages = with pkgs; [ nbxplorer ];

    systemd.services.nbxplorer = {
      description = "NBXplorer";
      wantedBy = [ "multi-user.target" ];
      script = optionalString (cfg.btcRpcAuthFile != null) ''
        RPCAUTH=$(${pkgs.coreutils}/bin/cat ${cfg.btcRpcAuthFile})
      '' +
      optionalString (cfg.btcRpcAuth != null) ''
        RPCAUTH="${cfg.btcRpcAuth}"
      '' +
      ''
        ${pkgs.nbxplorer}/bin/nbxplorer -d ${cfg.dataDir} -b ${cfg.bind} -p ${toString cfg.port} --btcrpcauth $RPCAUTH ${toString cfg.extraCmdLineOptions}
      '';

      serviceConfig = {
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
