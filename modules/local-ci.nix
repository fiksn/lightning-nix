{ pkgs, lib, config, ... }:
let
  cfg = config.local-ci;
  minuteStr = builtins.toString cfg.minutes;
in
{
  options.local-ci = {
    enable = lib.mkEnableOption "Whether to enable local CI";
    minutes = lib.mkOption {
      type = lib.types.int;
      description = "Minutes";
      default = 30;
    };
  };

  config = with cfg; lib.mkIf enable {
    systemd = {
      timers.local-ci = {
        description = "Automatically try to apply new settings - timer";
        partOf = [ "local-ci.service" ];
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = "*:0/${minuteStr}";
      };
      services.local-ci = {
        description = "Automatically try to apply new settings";
        serviceConfig.Type = "oneshot";
        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;
        script = ''
          set -euo pipefail
          cd /root/ln
          ${pkgs.git}/bin/git pull --rebase -s recursive -X ours | grep -q "Already up to date." && exit 0
          echo "Cronjob started at $(date)"
          export NIX_PATH=/root/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

          # Invoke tests
          for i in test/*.nix; do ${pkgs.nix}/bin/nix-shell $i; done

          ${config.system.build.nixos-rebuild}/bin/nixos-rebuild switch
          echo "Cronjob finished at $(date)"
        '';
      };
    };
  };
}
