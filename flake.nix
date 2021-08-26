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
      genModValue = dir: str: { config, options, lib, ... }: { imports = [ "/${dir}/${str}" ]; };
      genMachineValue = dir: str: lib.nixosSystem { system = "aarch64-linux"; modules = [ "/${dir}/${str}" ]; };
      oneFrom = gen: dir: str: { "${genKey str}" = gen dir str; };

      modulesFromDir = dir: builtins.foldl' (x: y: x // (oneFrom genModValue dir y)) { } (getNixFilesInDir dir);
      machinesFromDir = dir: builtins.foldl' (x: y: x // (oneFrom genMachineValue dir y)) { } (getNixFilesInDir dir);
    in
    {
      # Overlays
      overlay = callPackage ./overlay.nix;

      # Modules
      nixosModules = modulesFromDir ./modules;

      # Quasi modules (profiles)
      fakeProfiles = modulesFromDir ./profiles;

      # Machines (just demo, others are in private repo)
      nixosConfigurations = machinesFromDir ./machines //
      {
        vpsNode = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./machines/node.nix ];
        };
      };
    } //

    # Packages
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      { packages = flake-utils.lib.flattenTree (pkgs.callPackage ./pkgs { }); }
    );
}
