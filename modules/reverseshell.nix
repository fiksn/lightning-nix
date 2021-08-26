{ pkgs, lib, config, ... }:
let
  cfg = config.reverseshell;
in
{
  options.reverseshell = {
    enable = lib.mkEnableOption "Whether to enable reverse shell";
    server = lib.mkOption {
      type = lib.types.str;
      description = "Server";
    };
    key = lib.mkOption {
      type = lib.types.str;
      description = "Key";
      default = "";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port";
      default = 22;
    };
    options = lib.mkOption {
      type = lib.types.str;
      description = "-R1337:127.0.0.1:1338";
      default = "";
    };
  };

  config = with cfg; lib.mkIf enable {
    systemd.services.reverseshell = {
      description = "Reverse Shell Daemon";
      enable = true;
      script = ''
        while true; do
          ${pkgs.openssh}/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${builtins.toString cfg.port} ${cfg.options} ${cfg.server} ${lib.optionalString (cfg.key != "") "-i ${cfg.key}"} -N
          echo "Waiting 30 seconds before reconnect..."
          sleep 30;
        done
      '';
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      serviceConfig = {
        Type = "simple";
        Restart = "always";

        RestartSec = "30";
        StartLimitIntervalSec = "60";
        StartLimitBurst = "600";
      };
      wantedBy = [ "default.target" ];
    };
  };
}
