# 这是一个 flakeModule，经由 mkFlake -> evalFlakeModule -> evalModules 链路被执行
{ inputs, lib, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        # 允许安装非自由软件包
        config.allowUnfree = true;
        # 注意事项：
        #   - 使用 overlay 会影响整个 nixpkgs，可能导致大量软件包被重新构建
        #   - 建议优先使用 packages 下面的有限作用域进行包覆盖操作
        overlays =
          # 递归读取子目录下的 overlay.nix 文件
          lib.fileset.fileFilter (args: args.name == "overlay.nix") ./.
          # 转换为列表
          |> lib.fileset.toList
          # 导入每个 overlay.nix 文件
          |> lib.map (path: import path)
          # 添加 inputs 到 pkgs 中
          |> lib.concat [ (_: _: { inherit inputs; }) ];
      };
    };
}
