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
      genValue = dir: str: { config }: { imports = [ "/${dir}${str}" ]; };
      moduleFrom = dir: str: { "${genKey str}" = genValue dir str; };
      modulesFromDir = dir: builtins.foldl' (x: y: x // (moduleFrom dir y)) { } (getNixFilesInDir dir);
    in
    {
      # Overlays
      overlay = callPackage ./overlay.nix;

      # Modules
      nixosModules = modulesFromDir ./modules;
   
      # Machines (just demo, others are in private repo)
      nixosConfigurations = {
        example = lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./machines/example.nix ];
        };
      };
    } //
    # Packages
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      { packages = flake-utils.lib.flattenTree (pkgs.callPackage ./pkgs { }); }
    );
}

