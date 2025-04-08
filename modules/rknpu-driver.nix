{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:
stdenv.mkDerivation rec {
  pname = "rknpu-driver";
  version = "${kernel.version}-unstable-rk-6.1-rkr5";

  src = fetchFromGitHub {
    owner = "armbian";
    repo = "linux-rockchip";
    rev = "28320e8543bb19e21d3cfbf0421c700f17da5b58";
    sha256 = "sha256-nW6i4IRqN3CWnjDDhHP4/V8oYSNQkEmAo5AddacClNg=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = ["modules"];

  buildPhase = ''
    runHook preBuild
    local moduleSrcDirReadOnly="$src/drivers/rknpu"
    local moduleSrcDirWritable="$PWD/rknpu-src-build"
    mkdir -p "$moduleSrcDirWritable"
    cp -r "$moduleSrcDirReadOnly"/* "$moduleSrcDirWritable/"
    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" M="$moduleSrcDirWritable" $makeFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    local modDestDir="$out/lib/modules/${kernel.modDirVersion}/extra"
    mkdir -p "$modDestDir"
    local moduleSrcDirWritable="$PWD/rknpu-src-build"
    find "$moduleSrcDirWritable" -name '*.ko' -exec cp {} "$modDestDir/" \;
    runHook postInstall
  '';

  meta = with lib; {
    description = "Rockchip NPU driver (out-of-tree, rk-6.1-rkr5 branch)";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
