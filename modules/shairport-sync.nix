{pkgs, ...}: {
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    package = pkgs.shairport-sync.override {
      # Audio output
      enableAlsa = true;
      enableAo = false;
      enableJack = false;
      enablePipe = false;
      enablePipewire = false;
      enablePulse = false;
      enableSndio = false;
      enableSoundio = false;
      # Audio options
      enableAlac = true;
      enableConvolution = false;
      enableSoxr = true;
      # Metadata
      enableMetadata = false;
      # IPC
      enableDbus = false;
      enableMpris = false;
      enableMqttClient = false;
    };
    settings = {
      diagnostics = {
        log_verbosity = 0;
      };
      general = {
        output_backend = "alsa";
      };
    };
  };
}
