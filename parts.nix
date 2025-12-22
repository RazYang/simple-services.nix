{ lib, inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
  ];

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  _module.args.infuse = (import inputs.infuse { inherit lib; }).v1.infuse;

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
