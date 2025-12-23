{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = {
    treefmt.flakeCheck = false;
    treefmt.programs.nixfmt = {
      enable = true;
      strict = true;
    };
  };
}
