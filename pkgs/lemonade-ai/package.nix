{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  libdrm,
  pkg-config,
  curl,
  nlohmann_json,
  openssl,
  zstd,
  cli11,
  buildNpmPackage,
  fetchNpmDeps,
  libwebsockets,
  libnotify,
  libappindicator-gtk3,
  nix-update-script,
  nodejs,
  lemonadeAiLockfile,
}:
let
  version = "10.2.0";
  webAppSourceRoot = "${src.name}/src/web-app";
  webAppPostPatch = ''
    cp ${lemonadeAiLockfile} package-lock.json
    chmod u+w package-lock.json

    # The PR lockfile was generated from a nearby upstream snapshot. Patch the
    # root package metadata so npm accepts it for the 10.2.0 web-app tree.
    node <<'EOF'
    const fs = require("fs");
    const lockfilePath = "package-lock.json";
    const lockfile = JSON.parse(fs.readFileSync(lockfilePath, "utf8"));
    const root = lockfile.packages[""];

    delete root.devDependencies.eventsource;
    delete root.devDependencies["lucide-react"];
    root.overrides = { lodash: "~4.17.21" };

    fs.writeFileSync(lockfilePath, JSON.stringify(lockfile, null, 2) + "\n");
    EOF
  '';

  src = fetchFromGitHub {
    owner = "lemonade-sdk";
    repo = "lemonade";
    rev = "v${version}";
    hash = "sha256-r6b98zW+guE27HZe26MiQhlHIltfZyNPRN7HIdpKrYI=";
  };

  httplib-src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v0.26.0";
    hash = "sha256-+VPebnFMGNyChM20q4Z+kVOyI/qDLQjRsaGS0vo8kDM=";
  };

  web-app = buildNpmPackage {
    pname = "lemonade-web-app";
    inherit version src;
    sourceRoot = webAppSourceRoot;
    postPatch = webAppPostPatch;

    npmDeps = fetchNpmDeps {
      name = "lemonade-web-app-${version}-npm-deps";
      hash = "sha256-+2nxaPm4765Y9kM5C3hM///3Dg+HnM6b4btGz6z85i8=";
      inherit src;
      sourceRoot = webAppSourceRoot;
      postPatch = webAppPostPatch;
      nativeBuildInputs = [ nodejs ];
    };

    postInstall = ''
      mkdir $out/resources
      cp -r dist/renderer/ $out/resources/web-app/
    '';
  };
in
stdenv.mkDerivation {
  pname = "lemonade-ai";
  inherit version src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    libwebsockets
  ];

  buildInputs = [
    curl
    nlohmann_json
    openssl
    zstd
    cli11
    libdrm
    libnotify
    libappindicator-gtk3
  ];

  cmakeFlags = [
    "-DUSE_SYSTEM_JSON=ON"
    "-DUSE_SYSTEM_CLI11=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_ZSTD=ON"
    "-DUSE_SYSTEM_HTTPLIB=OFF"
    "-DFETCHCONTENT_SOURCE_DIR_HTTPLIB=${httplib-src}"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  ];

  env.NIX_LDFLAGS = "-lssl -lcrypto";

  postPatch = ''
    # Prevent CMake from trying to create symlinks in /usr/bin and /usr/lib.
    substituteInPlace src/cpp/tray/CMakeLists.txt \
      --replace-warn 'if(NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr")' 'if(FALSE)' \
      --replace-warn 'if(UNIX AND NOT APPLE AND NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr")' 'if(FALSE)'

    substituteInPlace src/cpp/cli/CMakeLists.txt \
      --replace-warn 'if(UNIX AND NOT APPLE AND NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr")' 'if(FALSE)'

    substituteInPlace src/cpp/legacy-cli/CMakeLists.txt \
      --replace-warn 'if(UNIX AND NOT APPLE AND NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr")' 'if(FALSE)'

    substituteInPlace CMakeLists.txt \
      --replace-warn 'if(NOT CMAKE_INSTALL_PREFIX STREQUAL "/usr")' 'if(FALSE)'

    # Prevent CMake from touching /etc.
    substituteInPlace CMakeLists.txt \
      --replace-warn 'DESTINATION /etc/lemonade' 'DESTINATION ''${CMAKE_INSTALL_PREFIX}/etc/lemonade'
  '';

  postInstall = ''
    mkdir -p $out/bin/resources/web-app
    cp -r $src/src/cpp/resources/* $out/bin/resources
    chmod -R +w $out/bin/resources/
    cp -r ${web-app}/resources/web-app/* $out/bin/resources/web-app/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Run local AI models through Lemonade's server and companion tooling";
    homepage = "https://lemonade-server.ai/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ videl ];
    mainProgram = "lemonade-server";
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
