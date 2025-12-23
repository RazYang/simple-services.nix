{
  writeTextFile,
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
  process-compose-conf = writeTextFile {
    name = "process-compose.json";
    text = builtins.toJSON {
      processes = {
        hello.command = "while true; do ${hello_2_11}/bin/hello; ${s6-portable-utils}/bin/s6-sleep 1; done";
        redis.command = "${redis}/bin/redis-server --port 5552";
      };
    };
  };
  APPID =
    process-compose-conf.outPath
    |> builtins.baseNameOf
    |> lib.splitString "-"
    |> lib.flip builtins.elemAt 0;
  svc-name = builtins.baseNameOf ./.;
in
lib.fix (
  finalDrv:
  writeShellApplication {
    name = svc-name;
    text = ''
      PC_SOCKET_PATH="/tmp/${APPID}.sock" \
      PC_CONFIG_FILES="${process-compose-conf}" \
      PC_LOG_FILE="/tmp/${APPID}.log" \
      ${process-compose}/bin/process-compose "$@"
    '';

    passthru = {
      tarball =
        runCommand "${svc-name}.tar.gz" { closure = closureInfo { rootPaths = [ finalDrv ]; }; }
          ''
            tar czf - $(cat $closure/store-paths) > $out
          '';
      ociImage = dockerTools.buildImage {
        name = svc-name;
        tag = "latest";
        copyToRoot = [
          bash
          finalDrv
        ];
      };
    };
  }
)
