{
  pkgs,
  lib,
  kernel ? pkgs.linuxPackages_latest.kernel,
  patches ? [],
}:
pkgs.stdenv.mkDerivation {
  pname = "amdgpu-kernel-module";
  inherit (kernel) src version patches postPatch nativeBuildInputs;

  kernel_dev = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  modulePath = "drivers/gpu/drm/amd/amdgpu";

  buildPhase = ''
    BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config        .
    cp $kernel_dev/vmlinux          .

    make "-j$NIX_BUILD_CORES" modules_prepare
    make "-j$NIX_BUILD_CORES" M=$modulePath modules
  '';

  installPhase = ''
    make \
      INSTALL_MOD_PATH="$out" \
      XZ="xz -T$NIX_BUILD_CORES" \
      M="$modulePath" \
      INSTALL_MOD_STRIP=1 \
      modules_install
  '';

  meta = {
    license = lib.licenses.gpl3;
  };
}
