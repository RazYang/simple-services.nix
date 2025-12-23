# Redis 包的定制配置
# 使用 infuse 对 nixpkgs 中的 redis 包进行有限作用域的覆盖
#
# 参数来源：
#   - infuse: 来自 overlays/default.nix，通过 overlay 机制被添加到 pkgs 中
#             其他pkgs中的包也可以通过此方式引入
#   - pkgs: pkgs本体，因为这里导出的包也叫redis，使用pkgs.redis避免循环引用
{ infuse, pkgs, ... }:
infuse pkgs.redis {
  # 输入参数覆盖：效果等同于override
  __input = {
    withSystemd = _: false;
    tlsSupport = _: false;
    useSystemJemalloc = _: false;
  };
  # 属性覆盖：效果等同于overrideAttrs
  __output = {
    doCheck = _: false;
    makeFlags.__append = [ "MALLOC=libc" ];
  };
}
