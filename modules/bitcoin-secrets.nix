{ config, lib, pkgs, ... }:

with lib;
let
  convert = builtins.toFile "convert.py" (pkgs.lib.readFile ./config/convert.py);
  cfg = config.services.bitcoin-secrets;
  # fooTemplater is an ugly hack
  fooTemplater = string: foos: map (x: builtins.replaceStrings [ "%FOO%" ] [ x ] string) foos;
  template = ''
    if [ ! -f ${cfg.dataDir}/%FOO%-bitcoin-rpc ]; then
      PASS=$(${pkgs.coreutils}/bin/tr -dc A-Za-z0-9_ < /dev/urandom | ${pkgs.coreutils}/bin/head -c 16 | ${pkgs.findutils}/bin/xargs)
      ${pkgs.coreutils}/bin/echo $PASS > ${cfg.dataDir}/%FOO%-bitcoin-rpc

      HASH=$(${pkgs.python3}/bin/python ${convert} $PASS)
      ${pkgs.coreutils}/bin/echo -e "rpcauth=%FOO%:$HASH" > ${cfg.dataDir}/bitcoin-%FOO%.conf
    fi
  '';

  script = pkgs.writeShellScriptBin "script" (''
    umask 337
    ${pkgs.coreutils}/bin/mkdir -m 0770 -p ${cfg.dataDir}
  '' + builtins.concatStringsSep "\n" (fooTemplater template cfg.services) + ''
    ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
  '');
in
{
  options.services.bitcoin-secrets = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, the secret service will be installed.
      '';
    };
    dataDir = mkOption {
      type = types.path;
      default = "/secrets";
      description = "The data directory for secrets.";
    };
    user = mkOption {
      type = types.str;
      default = "keys";
      description = "The user as which to run secrets.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run secrets.";
    };
    services = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "lnd" ];
      description = ''
        Secrets for which services to generate.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      description = "Key holder";
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {
      name = cfg.group;
    };

    systemd.services.bitcoin-secrets = {
      description = "Run bitcoin-secrets";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${script}/bin/script";
        Type = "oneshot";
        RemainAfterExit = "true";
        User = "root";
      };
    };
  };
}
