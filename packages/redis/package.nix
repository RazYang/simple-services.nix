# 这是一个拥有独立作用域的，使用callPackage设计模式的软件包定义函数，与nixpkgs中软件包的定义方式基本相同：
# https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/he/hello/package.nix
#
# infuse: 来自 overlays/default.nix，通过 overlay 机制被添加到 pkgs 中
# pkgs: pkgs本体，因为这个包也叫redis，使用pkgs.redis避免循环引用
{ infuse, pkgs, ... }:
infuse pkgs.redis {
  # 输入参数覆盖：效果等同于override
  __input = {
    tlsSupport.__assign = false;
    withSystemd.__assign = false;
    useSystemJemalloc = _: false; # 等价于useSystemJemalloc.__assign = false;
  };
  # 属性覆盖：效果等同于overrideAttrs
  __output = {
    doCheck.__assign = false;
    makeFlags.__append = [ "MALLOC=libc" ];
  };
}
# infuse提供了override以及overrideAttrs的语法糖:
# https://codeberg.org/amjoseph/infuse.nix/src/branch/trunk
# 如果不使用infuse，则可以写成：
/*
  (pkgs.redis.override ({
    withSystemd = false;
    tlsSupport = false;
    useSystemJemalloc = false;
  })).overrideAttrs
    (prevAttrs: {
      doCheck = false;
      makeFlags = prevAttrs.makeFlags ++ [ "MALLOC=libc" ];
    })
*/
