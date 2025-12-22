{
  hello-custom,
  writeTextFile,
  writeShellApplication,
  process-compose,
  s6-portable-utils,
  dockerTools,
  runCommand,
  closureInfo,
  bash,
  lib,
  self',
  ...
}:
let
  process-compose-conf = writeTextFile {
    name = "process-compose.json";
    text = builtins.toJSON {
      processes = {
        sleep = {
          command = "${s6-portable-utils}/bin/s6-sleep 100";
        };
        hello = {
          command = "while true; do ${hello-custom}/bin/hello; ${s6-portable-utils}/bin/s6-sleep 1; done";
        };
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
