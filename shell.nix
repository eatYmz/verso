with import <nixpkgs> { };

let
  nixgl = import (fetchTarball "https://github.com/nix-community/nixGL/archive/489d6b095ab9d289fe11af0219a9ff00fe87c7c5.tar.gz") { enable32bits = false; };
  pkgs_gnumake_4_3 = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/6adf48f53d819a7b6e15672817fa1e78e5f4e84f.tar.gz") { };
  llvmPackages = llvmPackages_14; # servo/servo#31059
  stdenv = stdenvAdapters.useMoldLinker llvmPackages.stdenv;
in
stdenv.mkDerivation {
  name = "verso-env";

  buildInputs = [
    fontconfig
    freetype
    libunwind
    xorg.libxcb
    xorg.libX11
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    libxkbcommon
    zlib
    vulkan-loader
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    rustup
    taplo
    llvmPackages.bintools
    llvmPackages.llvm
    llvmPackages.libclang
    udev
    cmake
    dbus
    gcc
    git
    pkg-config
    which
    llvm
    perl
    yasm
    m4
    pkgs_gnumake_4_3.gnumake # servo/mozjs#375
    libGL
    mold
    wayland
    nixgl.auto.nixGLDefault
    (python3.withPackages (ps: with ps; [pip dbus mako]))
  ];

  # 设置环境变量，确保库和工具能被正确找到
  LD_LIBRARY_PATH = lib.makeLibraryPath [
    xorg.libX11
    xorg.libxcb
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    libxkbcommon
    vulkan-loader
    wayland
    libGL
    nixgl.auto.nixGLDefault
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  
  # 设置 CA 证书路径，用于 Cargo 下载 crates
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  # 启用 Cargo 和 Rustc 的彩色输出
  TERMINFO = "${ncurses.out}/share/terminfo";

  # 设置 PKG_CONFIG_PATH，确保 pkg-config 能找到 x11.pc 文件
  PKG_CONFIG_PATH = "${xorg.libX11.dev}/lib/pkgconfig:${xorg.libxcb.dev}/lib/pkgconfig:${xorg.libXrandr.dev}/lib/pkgconfig:${xorg.libXi.dev}/lib/pkgconfig";
}
