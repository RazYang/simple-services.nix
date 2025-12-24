# 这是一个拥有独立作用域的，使用callPackage设计模式的软件包定义函数，与nixpkgs中软件包的定义方式基本相同：
# https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/he/hello/package.nix
{
  writers,
  writeShellApplication,
  process-compose,
  redis,
  hello_2_11,
  s6-portable-utils,
  dockerTools,
  runCommand,
  closureInfo,
  bash,
  lib,
  ...
}:
let
  # ============================================================================
  # svcName: 服务名称
  # ============================================================================
  svcName = builtins.baseNameOf ./.;

  # ============================================================================
  # APPID: 使用配置文件的nix store path作为APPID
  # ============================================================================
  APPID = svcConf |> builtins.baseNameOf |> lib.splitString "-" |> lib.flip builtins.elemAt 0;

  # ============================================================================
  # svcConf: process-compose配置文件
  # ============================================================================
  svcConf = writers.writeJSON "process-compose.json" {
    processes.redis.command = "${redis}/bin/redis-server --port 5552";
    processes.hello.command = "while true; do ${hello_2_11}/bin/hello; ${s6-portable-utils}/bin/s6-sleep 1; done";
  };

  # ============================================================================
  # finalDrv: 最终的软件包
  # ============================================================================
  finalDrv = writeShellApplication {
    name = svcName;
    # 启动脚本，使用process-compose加载svcConf，启动所有服务
    text = ''exec ${process-compose}/bin/process-compose "$@"'';
    # 环境变量设置
    runtimeEnv = {
      PC_SOCKET_PATH = "/tmp/${APPID}.sock";
      PC_CONFIG_FILES = svcConf;
      PC_LOG_FILE = "/tmp/${APPID}.log";
    };

    # 透传一些属性，方便构建服务的闭包/镜像/或其他格式
    passthru = {
      # 将所有依赖打包成tar.gz，其中只包含/nix/路径
      tarball = runCommand "${svcName}.tar.gz" { closure = closureInfo { rootPaths = [ finalDrv ]; }; } ''
        tar czf - $(cat $closure/store-paths) > $out
      '';
      # OCI镜像，其中只包含bash以及对应服务的启动命令
      ociImage = dockerTools.buildImage {
        name = svcName;
        tag = "latest";
        copyToRoot = [
          bash
          finalDrv
        ];
      };
    };
  };
in
finalDrv
