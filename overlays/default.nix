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
        # 导入所有子目录下的 overlay.nix 文件作为 overlay
        # 额外添加 infuse 作为 override 和 overrideAttrs 的语法糖
        #
        # 注意事项：使用 overlay 会影响整个 nixpkgs，可能导致大量包重复构建
        # 建议：优先使用 packages 下面的有限作用域进行包覆盖操作
        overlays =
          (
            lib.fileset.fileFilter ({ name, ... }: name == "overlay.nix") ./.
            |> lib.fileset.toList
            |> lib.map (path: import path)
          )
          ++ [ (final: _: { inherit ((import inputs.infuse { inherit (final) lib; }).v1) infuse; }) ];
      };
    };
}
