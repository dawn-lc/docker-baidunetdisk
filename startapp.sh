#!/bin/bash
set -e
ARCH=$(uname -m); case "$ARCH" in x86_64) ARCH=amd64;; i386|i686) ARCH=i386;; aarch64) ARCH=arm64;; armv7l) ARCH=armhf;; armv6l) ARCH=armel;; riscv64) ARCH=riscv64;; ppc64le) ARCH=ppc64el;; s390x) ARCH=s390x;; loongarch64) ARCH=loong64;; *) ARCH=unknown;; esac
APP_BIN="/opt/baidunetdisk/baidunetdisk"

fallback() {
  echo "[INFO] 使用软件渲染模式"
  export ELECTRON_DISABLE_GPU=1
  export LIBGL_ALWAYS_SOFTWARE=1
  export DISABLE_GLX=1
  exec "$APP_BIN" --no-sandbox --disable-gpu
  exit
}

if [[ "$ARCH" != "amd64" ]]; then
  fallback
fi

if lspci | grep -qi 'VGA.*Intel'; then
    echo "[INFO] 检测到 Intel GPU，安装 Intel VA 驱动..."
    apt-get update && apt-get install -y vainfo intel-media-va-driver i965-va-driver
    if LIBVA_DRIVER_NAME=iHD vainfo > /dev/null 2>&1; then
      echo "[INFO] 使用 Intel iHD 驱动 (硬件加速)"
      export ELECTRON_DISABLE_GPU=0
      export LIBGL_ALWAYS_SOFTWARE=0
      export DISABLE_GLX=0
      export LIBVA_DRIVER_NAME=iHD
      exec "$APP_BIN" --no-sandbox
    elif LIBVA_DRIVER_NAME=i965 vainfo > /dev/null 2>&1; then
      echo "[INFO] 使用 Intel i965 驱动 (旧版硬件加速)"
      export ELECTRON_DISABLE_GPU=0
      export LIBGL_ALWAYS_SOFTWARE=0
      export DISABLE_GLX=0
      export LIBVA_DRIVER_NAME=i965
      exec "$APP_BIN" --no-sandbox
    else
      echo "[WARN] Intel 驱动检测失败, 回退软件渲染"
      fallback
    fi
elif lspci | grep -qi 'VGA.*AMD'; then
    echo "[INFO] 检测到 AMD GPU，安装 AMD VA 驱动..."
    apt-get update && apt-get install -y vainfo mesa-va-drivers mesa-vdpau-drivers
    if vainfo > /dev/null 2>&1; then
      echo "[INFO] AMD VAAPI 驱动可用 (硬件加速)"
      export ELECTRON_DISABLE_GPU=0
      export LIBGL_ALWAYS_SOFTWARE=0
      export DISABLE_GLX=0
      exec "$APP_BIN" --no-sandbox
    else
      echo "[WARN] AMD 驱动检测失败, 回退软件渲染"
      fallback
    fi
elif lspci | grep -qi 'VGA.*NVIDIA'; then
    echo "[INFO] So Nvidia, F*ck you!"
    fallback
else
    echo "[WARN] 未检测到已知 GPU（或仅有虚拟显卡），回退软件渲染"
    fallback
fi
