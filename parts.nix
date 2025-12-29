# 这是一个 flakeModule，经由 mkFlake -> evalFlakeModule -> evalModules 链路被执行
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
  flake.defaultTemplate = {
    path = ./.;
    description = "";
  };
}
