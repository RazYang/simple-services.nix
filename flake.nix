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
