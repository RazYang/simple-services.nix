/*
  这个文件是flake的入口文件，用于定义flake的输入和输出。
  由于rfc193以及rfc194两个提案，这里倾向于将flake.nix当作go.mod，flake.lock当作go.sum。而parts.nix为flake outputs的入口点：
  https://github.com/NixOS/rfcs/pull/193
  https://github.com/NixOS/rfcs/pull/194
*/
{
  outputs =
    inputs: (inputs.flake-parts.lib.evalFlakeModule { inherit inputs; } ./parts.nix).config.flake;

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";
    flake-parts.url = "https://github.com/hercules-ci/flake-parts/archive/2cccadc.zip";
    treefmt-nix.url = "https://github.com/numtide/treefmt-nix/archive/5b4ee75.zip";
    infuse.url = "git+https://codeberg.org/amjoseph/infuse.nix.git";

    infuse.flake = false;
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  nixConfig.extra-substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nixConfig.experimental-features = [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];
}
