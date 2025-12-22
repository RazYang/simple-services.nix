{
  writers,
  writeTextFile,
  supervisord,
  ...
}:
let
  supervisorConf = writers.writeTOML "supervisor.conf" {
    supervisord = {
      pidfile = "/var/run/svc-hello.pid";
      minfds = 1024;
    };
  };
in
writeTextFile {
  name = "svc";
  executable = true;
  text = ''
    #!/bin/sh
    ${supervisord}/bin/supervisord -c ${supervisorConf}
  '';
}
