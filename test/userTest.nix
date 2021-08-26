{ pkgs ? import <nixpkgs> { }, ... }:
let
  lib = pkgs.lib;
  nixos = import <nixpkgs/nixos> { };
  check = f: msg: assert (lib.assertMsg f "FAIL ${msg}"); "PASS ${msg}";
  words = str: lib.filter (x: x != [ ]) (builtins.split " |\r|\n|\t" str);
  sum = list: builtins.foldl' (x: y: x + y) 0 list;
  normalUsers = builtins.filter (x: x.isNormalUser) (lib.toList (lib.attrValues nixos.config.users.users));
  users = normalUsers ++ (lib.toList nixos.config.users.users.root);
  normalUsernames = map (x: x.name) normalUsers;
  usernames = normalUsernames ++ [ "root" ];
  allOthers = lib.toList (lib.attrValues (builtins.removeAttrs nixos.config.users.users usernames));
  allOtherUsernames = map (x: x.name) allOthers;
  sanitizeSshKey = str: builtins.concatStringsSep " " (lib.take 2 (words str));
  allSshKeys = lib.unique (lib.flatten (map (x: getSshKey x) users));
  fileAllSshKeys = pkgs.writeText "all-ssh-keys.txt" (builtins.concatStringsSep "\n" allSshKeys);
  getSshKey = u: map sanitizeSshKey (u.openssh.authorizedKeys.keys ++ (map (f: lib.readFile f) u.openssh.authorizedKeys.keyFiles));
  sshKeysOfUser = user:
    let u = getUser user { openssh.authorizedKeys = { keys = [ ]; keyFiles = [ ]; }; }; in getSshKey u;
  hasSshKey = user: (sshKeysOfUser user) != [ ];
  getUser = user: default: if (nixos.config.users.users ? ${user}) then (builtins.elemAt (lib.attrValues (lib.getAttrs [ user ] nixos.config.users.users)) 0) else default;
  getGroup = group: default: if (nixos.config.users.groups ? ${group}) then builtins.elemAt (lib.attrValues (lib.getAttrs [ group ] nixos.config.users.groups)) 0 else default;
  isMemberOf = group: user: builtins.elem group ((getUser user { extraGroups = [ ]; }).extraGroups) || builtins.elem user ((getGroup group { members = [ ]; }).members);
  countMembersOf = group: users: sum (builtins.map (x: if (isMemberOf group x) then 1 else 0) users);
  whoHasSshKey = key: u: map (user: if (builtins.elem key (sshKeysOfUser user)) then 1 else 0) u;
  uniqueSshKey = key: u: sum (whoHasSshKey key u) <= 1;
  allSshKeysUnique = usersToCheck: builtins.foldl' (x: y: x && (uniqueSshKey y usersToCheck)) true allSshKeys;
  testRun = "Users:\n" + builtins.concatStringsSep "\n" usernames + "\n"
    + check (builtins.length users > 1) "More than 1 user\n"
    + check (builtins.all (x: !hasSshKey x) allOtherUsernames) "System users don't have ssh key\n"
    + check (builtins.all (x: hasSshKey x) normalUsernames) "Normal users have ssh key\n"
    + check (countMembersOf "wheel" usernames > 1) "At least 1 member of wheel group\n"
    + check (allSshKeysUnique normalUsernames) "All users have distinct ssh keys\n"
    + check (builtins.getEnv "CI" != "" || nixos.config.networking.useDHCP || builtins.length nixos.config.networking.interfaces.eth0.ipv4.addresses > 0) "Has some IPv4 address\n"
  ;
in
pkgs.mkShell {
  shellHook = ''
    echo "${testRun}"

    while read p; do
      echo $p | ${pkgs.openssh}/bin/ssh-keygen -l -f- > /dev/null || { echo "FAIL All ssh keys valid"; exit 1; }
    done < "${fileAllSshKeys}"
    echo "PASS All ssh keys valid"

    echo "Tests passed"
    exit 0
  '';
}
