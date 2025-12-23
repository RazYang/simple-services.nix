{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt.flakeCheck = false;
      treefmt.programs.nixfmt = {
        enable = true;
        strict = true;
      };
    };

}
