{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lightning-loop;
in
{
  options.services.lightning-loop = {
    enable = mkEnableOption "lightning-loop";
    package = mkOption {
      type = types.package;
      defaultText = "pkgs.nix-bitcoin.lightning-loop";
      description = "The package providing lightning-loop binaries.";
    };
    proxy = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Connect through SOCKS5 proxy";
    };
    extraArgs = mkOption {
      type = types.separatedString " ";
      default = "";
      description = "Extra command line arguments passed to loopd.";
    };
    cli = mkOption {
      readOnly = true;
      default =
        pkgs.writeScriptBin "loop"
          # Switch user because lnd makes datadir contents readable by user only
          ''
            exec sudo -u lnd ${cfg.package}/bin/loop "$@"
          '';
      description = "Binary to connect with the lnd instance.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.lnd.enable;
        message = "lightning-loop requires lnd.";
      }
    ];

    environment.systemPackages = [ cfg.package (hiPrio cfg.cli) ];

    systemd.services.loopd = {
      description = "Run loopd";
      wantedBy = [ "multi-user.target" ];
      requires = [ "lnd.service" ];
      after = [ "lnd.service" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/loopd \
          --lnd.macaroondir=${config.services.lnd.dataDir}/chain/bitcoin/mainnet \
          ${cfg.extraArgs}
        '';
        User = "lnd";
        Restart = "on-failure";
        RestartSec = "10s";
        #ReadWritePaths = "${config.services.lnd.dataDir}";
      };
    };
  };
}
