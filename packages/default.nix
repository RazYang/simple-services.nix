{
  lib,
  config,
  inputs,
  infuse,
  ...
}:
{
  perSystem =
    { pkgs, config, ... }:
    let
      # ============================================================================
      # 自指的艺术
      # ============================================================================
      toFix = self: {
        # ------------------------------------------------------------------------
        # callPackage: 创建包调用作用域
        # ------------------------------------------------------------------------
        # 参数:
        #   pkgsArg: pkgs 集合（可以是原生 pkgs 或交叉编译的 pkgs）
        # 返回:
        #   一个函数，用于调用包定义文件（package.nix）
        # 作用:
        #   合并多个作用域，使得包定义可以访问：
        #   - pkgsArg: 基础包集合
        #   - self.packages: 当前已构建的所有包（形成循环依赖）
        #   - inputs, infuse 等: 其他透传参数
        # ------------------------------------------------------------------------
        callPackage =
          pkgsArg:
          lib.callPackageWith (
            lib.mergeAttrsList [
              pkgsArg
              # 注意：这里引用了 self.packages，形成循环依赖
              # lib.fix 会延迟求值，直到 packages 被完全构建
              self.packages
              {
                inherit inputs infuse;
                inherit (config.allModuleArgs) self' inputs' system;
              }
            ]
          );

        # ------------------------------------------------------------------------
        # myPkgs: 扫描并构建当前目录下的所有包
        # ------------------------------------------------------------------------
        # 参数:
        #   callPackage: 用于调用包定义的函数（由 self.callPackage 提供）
        # 返回:
        #   属性集 { packageName = builtPackage }
        # 工作流程:
        #   1. 使用 lib.fileset 扫描 ./ 目录
        #   2. 过滤出所有名为 "package.nix" 的文件
        #   3. 对每个文件：
        #      - 提取所在目录名作为包名
        #      - 使用 callPackage 导入并构建包
        #   4. 转换为属性集返回
        # ------------------------------------------------------------------------
        myPkgs =
          callPackage:
          (
            lib.fileset.fileFilter ({ name, ... }: name == "package.nix") ./.
            |> lib.fileset.toList
            |> lib.map (path: {
              name = builtins.dirOf path |> builtins.baseNameOf;
              value = callPackage (import path) { };
            })
            |> lib.listToAttrs
          );

        # ------------------------------------------------------------------------
        # packages: 主包集合（包含原生包和交叉编译包）
        # ------------------------------------------------------------------------
        # 结构:
        #   {
        #     # 原生架构的包
        #     package1 = ...;
        #     package2 = ...;
        #     ...
        #     # 交叉编译的包集合
        #     pkgsCross = {
        #       aarch64-linux = { package1 = ...; package2 = ...; ... };
        #       x86_64-windows = { package1 = ...; package2 = ...; ... };
        #       ...
        #     };
        #   }
        # 构建流程:
        #   1. 使用 self.myPkgs 扫描并构建原生包
        #      - 传入 self.callPackage pkgs 作为 callPackage 函数
        #   2. 合并交叉编译包集合 pkgsCross
        #      - 为每个交叉编译系统构建对应的包集合
        #      - 使用 pkgs.pkgsCross."${crossSystem}" 作为 pkgsArg
        # ------------------------------------------------------------------------
        packages = (self.myPkgs (self.callPackage pkgs)) // {
          pkgsCross =
            (pkgs.writeText "pkgsCross" "")
            // (
              lib.map (crossSystem: {
                name = crossSystem;
                value = self.myPkgs (self.callPackage pkgs.pkgsCross."${crossSystem}");
              }) (lib.attrNames lib.systems.examples)
              |> lib.listToAttrs
            );
        };
      };
    in
    {
      # 使用 lib.fix 解决循环依赖问题
      # lib.fix 会延迟求值，直到所有递归引用都被解析
      inherit (lib.fix toFix) packages;
    };
}
