{ lib, inputs, ... }:
{
  imports = [
    ./treefmt.nix
    ./packages
    ./overlays
  ];

  systems = [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
