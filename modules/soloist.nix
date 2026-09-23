{
  config,
  pkgs,
  pkgsSoloist,
  secretsPath,
  ...
}:
let
  # https://github.com/spotify/soloist/issues/1
  # https://github.com/spotify/soloist/issues/4
  soloistReuseportPin = pkgs.stdenv.mkDerivation {
    pname = "soloist-reuseport-pin";
    version = "1";
    src = ../patches/soloist/soloist-reuse-port-pin-connect.c;
    dontUnpack = true;
    buildPhase = ''
      $CC -shared -fPIC -O2 -o reuseportpin.so "$src" -ldl
    '';
    installPhase = ''
      mkdir -p $out/lib
      install -m644 reuseportpin.so $out/lib/reuseportpin.so
    '';
  };
in
{
  age.secrets.soloist = {
    file = "${secretsPath}/soloist.age";
    mode = "640";
    owner = "soloist";
    group = "soloist";
  };

  networking.firewall.interfaces.enP4p65s0.allowedTCPPorts = [ 32768 ];

  services.soloist = {
    enable = true;
    apiKeyFile = config.age.secrets.soloist.path;
    initialVolume = 100;
    package = pkgsSoloist.soloist;
  };

  systemd.services.soloist = {
    environment = {
      LD_PRELOAD = "${soloistReuseportPin}/lib/reuseportpin.so";
      SOLOIST_CONNECT_PORT = "32768";
    };
    serviceConfig = {
      LimitCORE = 0;
      LogFilterPatterns = [ "~spotify:track:" ];
    };
  };
}
