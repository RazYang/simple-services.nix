# simple-services.nix

一个使用 flake-parts 组织的 Nix flake 项目，演示如何使用 nix 进行简单的服务封装，项目遵循以下原则：

1. 有限作用域进行包声明/覆盖，尽量避免影响整个 nixpkgs。
2. 使用包的组合，加上[process-compose](https://github.com/F1bonacc1/process-compose)以实现简单易懂的包声明。
3. KISS 原则，尽量保证每个部分相对简单，容易修改和扩展。

nix 生态内已经包含了太多概念：

- [derivation](https://nix.dev/manual/nix/2.25/language/derivations)
- [callPackage](https://nixos.org/guides/nix-pills/13-callpackage-design-pattern.html)
- [evalModule](https://nix.dev/tutorials/module-system/a-basic-module/index.html)
- [override](https://nixos.org/guides/nix-pills/17-nixpkgs-overriding-packages.html)
- [fixPoint](https://akavel.github.io/post/nix-fixpoint/)
- [flake](https://wiki.nixos.org/wiki/Flakes)
- [nix bundler](https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-bundle)
- ...

而且概念还在持续增加：

- [dynamic derivation](https://github.com/NixOS/rfcs/blob/master/rfcs/0092-plan-dynamism.md)
- [content address derivation](https://github.com/NixOS/rfcs/blob/master/rfcs/0062-content-addressed-paths.md)
- [Dendritic Pattern](https://github.com/mightyiam/dendritic)
- ...

更不要说在这些概念之上的各种项目：

- [uv2nix](https://github.com/pyproject-nix/uv2nix)
- [crane](https://github.com/ipetkov/crane)
- [home-manager](https://github.com/nix-community/home-manager)
- [nixos](https://nixos.org/manual/nixos/stable/)
- [nix-darwin](https://nix-darwin.github.io/nix-darwin/manual/)
- [dream2nix](https://github.com/nix-community/dream2nix)
- [devenv](https://devenv.sh/)
- [devbox](https://www.jetify.com/devbox)
- ...

本项目希望通过大致兼容 nixpkgs 中包声明写法的前提下，减少设计模式的使用和暴露，让更多的人快速将 nix 带到自己的开发流程中。

如果你不知道怎么去构建特定的包，_**JUST COPY FROM NIXPKGS**_

## 项目结构

```
.
├── flake.nix            # Flake 入口文件，定义输入和输出
├── parts.nix            # Flake outputs 的入口点（遵循 RFC 193/194）
├── treefmt.nix          # Treefmt 格式化工具配置
├── overlays/
│   │── default.nix      # overlays入口文件
│   └── 子目录           # 自动导入
│       └── overlay.nix  # 自动导入
└── packages/
    ├── default.nix      # packages入口文件
    └── 子目录           # 自动导入
        └── package.nix  # 自动导入
```
### 快速开始
``` bash
$ nix flake new -t github:RazYang/simple-services.nix ./myflake
$ cd myflake
# 接下来，mkdir packages/your-package
#         touch packages/your-package/package.nix
#         编写你自己的包
```

## 核心特性

### 1. 有限作用域的 package 构建声明

项目优先使用 `packages/` 目录下的软件包，而不是使用 nixpkgs 的 overlay 机制。这种方式：

- ✅ **避免影响整个 nixpkgs**：只影响当前包，不会导致大量包重复构建
- ✅ **更清晰的 monorepo**：所有自定义的包都在`packages`目录下
- ✅ **保留覆盖 nixpkgs 的可能性**：仍可以使用 overlay 为特定包打 patch，如修复安全漏洞

### 2. 使用 infuse 作为 override/overrideAttrs 的语法糖

项目使用 [infuse.nix](https://codeberg.org/amjoseph/infuse.nix) 作为 `override` 和 `overrideAttrs` 的语法糖，使包覆盖代码更加简洁易读。

**使用 infuse 的示例**（`packages/redis/package.nix`）：

```nix
infuse pkgs.redis {
  __input = {
    withSystemd = _: false;
    tlsSupport = _: false;
    useSystemJemalloc = _: false;
  };
  __output = {
    doCheck = _: false;
    makeFlags.__append = [ "MALLOC=libc" ];
  };
}
```

**等价于传统写法**：

```nix
(pkgs.redis.override {
  withSystemd = false;
  tlsSupport = false;
  useSystemJemalloc = false;
}).overrideAttrs (prevAttrs: {
  doCheck = false;
  makeFlags = prevAttrs.makeFlags ++ [ "MALLOC=libc" ];
})
```

### 3. 简单易用的交叉编译

`packages/default.nix` 额外扩展了`packages`输出，额外支持：

- 支持交叉编译（`pkgsCross`）
- 支持静态链接（`pkgsStatic`）

只需要在`packages`目录下，按照`nixpkgs`的规范声明 package，就天然支持交叉编译

### 4. 简单易懂的服务声明

利用`process-compose`为多个 package 封装服务，JSON 即服务，简单易懂

### 5. 代码简单

以上这一切都在 170 行代码以内实现

## 使用方法

### 构建特定包

```bash
# 构建 redis 包
nix build .#redis

# 构建 hello_2_11 包
nix build .#hello_2_11

# 构建服务组合包
nix build .#svc-hello

# 交叉编译
nix build .#pkgsCross.aarch64-multiplatform.hello_2_11
```

### 构建容器镜像/压缩包

```bash
# 构建服务组合包的oci镜像
nix build .#svc-hello.ociImage

# 交叉编译
nix build .#pkgsCross.aarch64-multiplatform.svc-hello.ociImage

# 构建服务组合包的tar包（包含所有依赖项）
nix build .#svc-hello.tarball

# 交叉编译
nix build .#pkgsCross.aarch64-multiplatform.svc-hello.tarball
```

### 格式化代码

```bash
nix fmt
```

## 示例包说明

### redis

演示如何使用 `infuse` 覆盖 nixpkgs 中 Redis 包的构建参数：

- 禁用 systemd 支持
- 禁用 TLS 支持
- 禁用 jemalloc，使用 libc 的 malloc
- 禁用测试以加快构建

### hello_2_11

演示如何从零开始定义一个包，使用标准的 `stdenv.mkDerivation`。

### svc-hello

演示如何组合多个服务：

- 使用 `process-compose` 管理多个进程
- 包含 Redis 和 Hello 服务
- 提供 OCI 镜像构建（`ociImage`）
- 将服务以及服务的所有依赖包打包为压缩包（`tarball`）

## Flake Inputs

项目使用以下 flake inputs：

- **nixpkgs**: Nix 包集合（使用清华大学镜像）
- **flake-parts**: Flake 模块化工具
- **treefmt-nix**: 代码格式化工具
- **infuse**: 包覆盖语法糖

当然，你可以增加任何 flake 的依赖项，并通过`flake-parts`模块的`inputs`或`inputs'`参数使用。
在 package 声明时，本项目封装的`callPackage`也将`inputs`以及`inputs'`带到了作用域内。

## 注意事项

### Overlay 的影响范围

虽然项目在 `overlays/default.nix` 中定义了 overlay（用于添加 `infuse`），但：

⚠️ **注意事项**：使用 overlay 会影响整个 nixpkgs，可能导致大量包重复构建。

✅ **建议**：优先使用 `packages/` 下面的有限作用域进行包覆盖操作。

### callPackage 的额外参数

在 `packages/*/package.nix` 中：

- `infuse`: 来自 `overlays/default.nix`，通过 overlay 机制被添加到 `pkgs` 中
- `pkgs`: pkgs 本体，当包名与 nixpkgs 中的包名相同时，使用 `pkgs.packageName` 避免循环引用
- `inputs`: flake inputs，使用方式为 inputs'.inputA.packages.${system}.PackageA
- `inputs'`: flake inputs with system，简化写法，使用方式为 inputs'.inputA.packages.PackageA
- 其他参数：通过 `callPackage` 的作用域合并机制自动注入，包含 pkgs 以及当前作用域下的所有包

## 参考资源

- [RFC 193: Flake structure](https://github.com/NixOS/rfcs/pull/193)
- [RFC 194: Flake lock file](https://github.com/NixOS/rfcs/pull/194)
- [infuse.nix](https://codeberg.org/amjoseph/infuse.nix)
- [flake-parts](https://github.com/hercules-ci/flake-parts)
- [treefmt-nix](https://github.com/numtide/treefmt-nix)
