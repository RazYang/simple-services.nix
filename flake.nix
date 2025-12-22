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
    process-compose-flake.url = "https://github.com/Platonic-Systems/process-compose-flake/archive/3667881.zip";
    services-flake.url = "https://github.com/juspay/services-flake/archive/8b6244f.zip";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "https://github.com/hercules-ci/flake-parts/archive/2cccadc.zip";
    };
    infuse = {
      flake = false;
      url = "git+https://codeberg.org/amjoseph/infuse.nix.git";
    };
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://github.com/numtide/treefmt-nix/archive/5b4ee75.zip";
    };
    flake-compat = {
      url = "https://github.com/NixOS/flake-compat/archive/65f2313.zip";
      flake = false;
    };
  };
}
