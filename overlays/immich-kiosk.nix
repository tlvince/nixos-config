final: prev: let
  inherit (prev) fetchFromGitHub pnpm_9;
in {
  immich-kiosk = prev.immich-kiosk.overrideAttrs (old: rec {
    version = "0.26.1";

    src = fetchFromGitHub {
      owner = "damongolding";
      repo = "immich-kiosk";
      tag = "v${version}";
      hash = "sha256-NsnJa5+P0xm12o7HAmfD8+w3H46f5WR2GO78My+YAi0=";
    };

    # Only delete vendor now
    postPatch = ''
      rm -rf vendor
    '';

    vendorHash = "sha256-Mx6dCC8xRTfE/7j4chLtdKzQLHQE9y+xtEasWPtn94k=";

    pnpmDeps = pnpm_9.fetchDeps {
      inherit (old) pname;
      inherit version src;
      sourceRoot = "${src.name}/frontend";
      hash = "sha256-En3y1fQRtwJm8fwxZ/VWuRfm1zPcnlDBuMNcY5WtxqM=";
      fetcherVersion = 2;
    };
  });
}
