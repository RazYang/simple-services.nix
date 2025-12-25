# 这是一个拥有独立作用域的，使用callPackage设计模式的软件包定义函数，与nixpkgs中软件包的定义方式基本相同：
# https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/he/hello/package.nix
{ stdenv, fetchurl, ... }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.11";
  src = fetchurl {
    url = "https://mirrors.tuna.tsinghua.edu.cn/gnu/hello/hello-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-jJzgVy08RO0GcOsc3pgFhOA4tvYsJf396O8SjeFQBL0=";
  };
})
