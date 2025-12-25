# ==============================================================================
# Flake 入口文件
# ==============================================================================
#
# 本文件用于定义 flake 的输入和输出。
# 根据 RFC 193 和 RFC 194 两个提案，这里倾向于将：
#   - flake.nix  当作 go.mod（依赖声明）
#   - flake.lock 当作 go.sum（锁定版本）
#   - parts.nix  作为 flake outputs 的入口点，即entrypoint
#
# 相关 RFC 提案：
#   - https://github.com/NixOS/rfcs/pull/193
#   - https://github.com/NixOS/rfcs/pull/194
#
#
{
  # ============================================================================
  # outputs: 输出
  # ============================================================================
  # 使用 flake-parts 来组织输出，入口点为 ./parts.nix
  # 如果rfc194顺利通过，这行大概率可以省掉
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./parts.nix;

  # ============================================================================
  # Flake 输入依赖
  # ============================================================================
  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";

    # flake-parts是好文明
    flake-parts.url = "https://github.com/hercules-ci/flake-parts/archive/2cccadc.zip";
    # 代码格式化工具，当然，去掉也没啥影响
    treefmt-nix.url = "https://github.com/numtide/treefmt-nix/archive/5b4ee75.zip";
    # infuse是好文明
    infuse.url = "git+https://codeberg.org/amjoseph/infuse.nix.git";

    infuse.flake = false;
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  # ============================================================================
  # Nix 配置选项
  # ============================================================================
  nixConfig = {
    # 使用清华大学镜像源作为二进制缓存
    extra-substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    # 启用的实验性功能
    experimental-features = [
      "flakes" # Flake 功能
      "nix-command" # 新的 nix 命令
      "pipe-operators" # 管道操作符
    ];
  };
}
