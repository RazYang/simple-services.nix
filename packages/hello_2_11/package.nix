{ stdenv, fetchurl, ... }:
stdenv.mkDerivation (finalAttr: {
  pname = "hello";
  version = "2.11";
  src = fetchurl {
    url = "https://mirrors.tuna.tsinghua.edu.cn/gnu/hello/hello-${finalAttr.version}.tar.gz";
    sha256 = "sha256-jJzgVy08RO0GcOsc3pgFhOA4tvYsJf396O8SjeFQBL0=";
  };
})
