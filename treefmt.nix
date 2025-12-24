# 这是一个 flakeModule，经由 mkFlake -> evalFlakeModule -> evalModules 链路被执行
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
