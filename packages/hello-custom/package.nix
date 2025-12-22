{ stdenv, fetchurl, ... }:
stdenv.mkDerivation {
  pname = "hello";
  version = "custom-2.12.1";
  src = fetchurl {
    url = "https://mirrors.tuna.tsinghua.edu.cn/gnu/hello/hello-2.12.1.tar.gz";
    sha256 = "jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };
}
