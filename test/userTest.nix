{ hostname ? "", flakePath ? /etc/nixos, pkgs ? import <nixpkgs> { }, ... }:
let
  lib = pkgs.lib;
  flake = builtins.getFlake (toString flakePath);
  check = f: msg: assert (lib.assertMsg f "FAIL ${msg}"); "PASS ${msg}";
  words = str: lib.filter (x: x != [ ]) (builtins.split " |\r|\n|\t" str);
  sum = list: builtins.foldl' (x: y: x + y) 0 list;

  normalUsers = config: builtins.filter (x: x.isNormalUser) (lib.toList (lib.attrValues config.users.users));
  users = config: (normalUsers config) ++ (lib.toList config.users.users.root);
  normalUsernames = config: map (x: x.name) (normalUsers config);
  usernames = config: (normalUsernames config) ++ [ "root" ];
  allOthers = config: lib.toList (lib.attrValues (builtins.removeAttrs config.users.users (usernames config)));
  allOtherUsernames = config: map (x: x.name) (allOthers config);

  sanitizeSshKey = str: builtins.concatStringsSep " " (lib.take 2 (words str));
  allSshKeys = config: lib.unique (lib.flatten (map (x: getSshKey x) (users config)));
  getSshKey = u: map sanitizeSshKey (u.openssh.authorizedKeys.keys ++ (map (f: lib.readFile f) u.openssh.authorizedKeys.keyFiles));
  sshKeysOfUser = config: user:
    let u = getUser config user { openssh.authorizedKeys = { keys = [ ]; keyFiles = [ ]; }; }; in getSshKey u;
  hasSshKey = config: user: (sshKeysOfUser config user) != [ ];

  whoHasSshKey = config: key: u: map (user: if (builtins.elem key (sshKeysOfUser config user)) then 1 else 0) u;
  uniqueSshKey = config: key: u: sum (whoHasSshKey config key u) <= 1;
  allSshKeysUnique = config: usersToCheck: builtins.foldl' (x: y: x && (uniqueSshKey config y usersToCheck)) true (allSshKeys config);

  fileAllSshKeys = configs: pkgs.writeText "all-ssh-keys.txt" (builtins.concatStringsSep "\n" (builtins.concatMap (config: allSshKeys config) configs));

  getUser = config: user: default: if (config.users.users ? ${user}) then (builtins.elemAt (lib.attrValues (lib.getAttrs [ user ] config.users.users)) 0) else default;
  getGroup = config: group: default: if (config.users.groups ? ${group}) then builtins.elemAt (lib.attrValues (lib.getAttrs [ group ] config.users.groups)) 0 else default;
  isMemberOf = config: group: user: builtins.elem group ((getUser config user { extraGroups = [ ]; }).extraGroups) || builtins.elem user ((getGroup config group { members = [ ]; }).members);
  countMembersOf = config: group: users: sum (builtins.map (x: if (isMemberOf config group x) then 1 else 0) users);

  testRunConfig = config: "Users:\n" + builtins.concatStringsSep "\n" (usernames config) + "\n"
    + check (builtins.length (users config) > 1) "More than 1 user\n"
    + check (builtins.all (x: !hasSshKey config x) (allOtherUsernames config)) "System users don't have ssh key\n"
    + check (builtins.all (x: hasSshKey config x) (normalUsernames config)) "Normal users have ssh key\n"
    # + check (countMembersOf config "wheel" (usernames config) > 1) "At least 1 member of wheel group\n"
    + check (allSshKeysUnique config (normalUsernames config)) "All users have distinct ssh keys\n"
    + check (builtins.getEnv "CI" != "" || config.networking.useDHCP || builtins.length config.networking.interfaces.eth0.ipv4.addresses > 0) "Has some IPv4 address\n";

  ###
  testRun =
    if hostname != "" then testRunConfig flake.nixosConfigurations.${hostname}.config
    else
      builtins.concatStringsSep "\n" (map (c: testRunConfig flake.nixosConfigurations.${c}.config) (lib.attrNames flake.nixosConfigurations));

  fileAllSshKeysRunner =
    if hostname != "" then fileAllSshKeys [ flake.nixosConfigurations.${hostname}.config ]
    else
      fileAllSshKeys (map (c: flake.nixosConfigurations.${c}.config) (lib.attrNames flake.nixosConfigurations));
  ###
in
pkgs.mkShell {
  shellHook = ''
    echo "${testRun}"

    while read p; do
      echo $p | ${pkgs.openssh}/bin/ssh-keygen -l -f- > /dev/null || { echo "FAIL All ssh keys valid"; exit 1; }
    done < "${fileAllSshKeysRunner}"
    echo "PASS All ssh keys valid"

    echo "Tests passed"
    exit 0
  '';
}
