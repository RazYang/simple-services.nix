{ lib, inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
  ];

  systems = [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
  ];

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config.allowUnfree = true;
        inherit system;
      };

      treefmt.flakeCheck = false;
      treefmt.programs.nixfmt = {
        enable = true;
        strict = true;
      };
    };
}
