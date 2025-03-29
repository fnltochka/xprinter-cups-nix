{ pkgs ? import <nixpkgs> { } }:

# This shell provides a development environment with cups and dpkg
pkgs.mkShell {
  buildInputs = with pkgs; [
    cups
    dpkg
  ];
} 