{
  outputs =
    inputs: (inputs.flake-parts.lib.evalFlakeModule { inherit inputs; } ./parts.nix).config.flake;

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
    extra-substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  };

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";
    flake-parts.url = "https://github.com/hercules-ci/flake-parts/archive/2cccadc.zip";
    treefmt-nix.url = "https://github.com/numtide/treefmt-nix/archive/5b4ee75.zip";
    flake-compat.url = "https://github.com/NixOS/flake-compat/archive/65f2313.zip";

    flake-compat.flake = false;
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
}
