# XPrinter CUPS Driver for NixOS

This repository contains a Nix package for XPrinter printer drivers. The package is based on the official `printer-driver-xprinter` deb package version 3.13.14.

## Installation

### Using Flakes (recommended)

Add this repository as an input in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xprinter-cups.url = "github:fnltochka/xprinter-cups-nix";
  };

  outputs = { self, nixpkgs, xprinter-cups, ... }:
    {
      nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          xprinter-cups.nixosModules.default
          {
            services.printing.drivers.xprinter.enable = true;
          }
        ];
      };
    };
}
```

### Using fetchFromGitHub

If you don't use flakes, you can install the package using `fetchFromGitHub` in your NixOS configuration:

```nix
{pkgs, ...}: let
  xprinter-driver = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "fnltochka";
      repo = "xprinter-cups-nix";
      rev = "main";
      sha256 = "sha256-J7DFgVd9uO9dHzv4hP6ivcmbCuIUZsxDhputG5zatrA=";
    }
  ) {};
in {
  services.printing = {
    enable = true;
    drivers = [xprinter-driver];
  };
}
```

## Supported Architectures

The package supports the following architectures:

- x86_64 (x64)
- i686 (x86)
- aarch64 (ARM64)
- armv7l (ARM 32-bit)

## CUPS Setup

After installing the driver, you need to:

1. Make sure the CUPS service is running: `sudo systemctl restart cups`
2. Open the CUPS web interface: `http://localhost:631`
3. Add a printer through the CUPS interface
4. When selecting a driver, find your model in the XPrinter list

## Troubleshooting

If you encounter issues with the driver:

1. Check CUPS logs: `journalctl -u cups`
2. Ensure your printer model is in the supported list (PPD files)
3. Make sure you selected the correct driver for your printer model
4. If you encounter a build error related to permissions:
   - Make sure you're using the latest version of the package
   - Try building the package in a clean environment: `nix-build --option sandbox true`
   - When using flakes, add the option `nix build --option sandbox true`

## License

This package is distributed under the same license as the original XPrinter driver.

## Localization

- [Russian version (Русская версия)](README.ru.md)
