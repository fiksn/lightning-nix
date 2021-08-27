{
  description = "Bitcoin Lightning Nix resouces";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
  };

  outputs = { self, flake-utils, nixpkgs }:
    with nixpkgs;
    let
      getNixFilesInDir = dir: builtins.filter (file: lib.hasSuffix ".nix" file && file != "default.nix") (builtins.attrNames (builtins.readDir dir));
      genKey = str: lib.replaceStrings [ ".nix" ] [ "" ] str;
      genModValue = dir: str: { config, options, lib, ... }: { imports = [ (dir + "/${str}") ]; };
      genMachineValue = dir: str: mkMachine "aarch64-linux" (dir + "/${str}");
      oneFrom = gen: dir: str: { "${genKey str}" = gen dir str; };

      modulesFromDir = dir: builtins.foldl' (x: y: x // (oneFrom genModValue dir y)) { } (getNixFilesInDir dir);
      machinesFromDir = dir: builtins.foldl' (x: y: x // (oneFrom genMachineValue dir y)) { } (getNixFilesInDir dir);

      # A cursed wrapper around lib.nixosSystem - trick is that you can't pass parameters easily to NixOS modules, so I've used this
      # https://stackoverflow.com/questions/47650857/nixos-module-imports-with-arguments#answer-58055106 idea
      mkMachine = arch: file: lib.nixosSystem {
        system = arch;
        modules = [ ({ pkgs, lib, config, options, ... } @ args: { nixpkgs.overlays = [ self.overlay ]; imports = [ (import file (args // { inherit self; })) ]; }) ];
      };
    in
    {
      # Overlays
      overlay = import ./overlay.nix;

      # Modules
      nixosModules = modulesFromDir ./modules;

      # Quasi modules (profiles)
      myProfiles = modulesFromDir ./profiles;

      # Machines (just demo, others are in private repo)
      nixosConfigurations = machinesFromDir ./machines //
      {
        vpsNode = mkMachine "x86_64-linux" ./machines/node.nix;
      };
    } //

    # Packages
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      { packages = flake-utils.lib.flattenTree (pkgs.callPackage ./pkgs { }); }
    );
}
