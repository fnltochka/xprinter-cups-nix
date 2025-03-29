{
  description = "XPrinter CUPS driver for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = rec {
          printer-driver-xprinter = pkgs.callPackage ./default.nix { };
          default = printer-driver-xprinter;
        };
      }
    ) // {
      nixosModules.default = { pkgs, lib, config, ... }:
        let
          cfg = config.services.printing.drivers.xprinter;
        in
        {
          options.services.printing.drivers.xprinter = {
            enable = lib.mkEnableOption "XPrinter driver support";
          };

          config = lib.mkIf cfg.enable {
            services.printing.drivers = [ self.packages.${pkgs.system}.printer-driver-xprinter ];
          };
        };
    };
} 