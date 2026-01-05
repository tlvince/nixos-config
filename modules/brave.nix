{ pkgs, ... }:
# https://github.com/prettymuchbryce/dotfiles/blob/54d70d7372523b74cafaf88bce5c7e31adcc37d0/modules/system/brave.md
let
  plist = pkgs.formats.plist { };

  bravePolicyPlist = plist.generate "com.brave.Browser.plist" {
    BraveAIChatEnabled = false;
    BraveLeoAssistantEnabled = false;
    BraveNewsDisabled = true;
    BraveP3AEnabled = false;
    BraveRewardsDisabled = true;
    BraveStatsPingEnabled = false;
    BraveSpeedreaderEnabled = false;
    BravePlaylistEnabled = false;
    BraveTalkDisabled = true;
    BraveVPNDisabled = true;
    BraveWalletDisabled = true;
    BraveWebDiscoveryEnabled = false;
    BrowserSignin = false;
    DefaultBrowserSettingEnabled = true;
    FeedbackSurveysEnabled = false;
    HttpsOnlyMode = "force_enabled";
    HttpsUpgradesEnabled = true;
    MetricsReportingEnabled = false;
    PasswordManagerEnabled = false;
    SafeBrowsingDeepScanningEnabled = false;
    SafeBrowsingExtendedReportingEnabled = false;
    SafeBrowsingSurveysEnabled = false;
    TorDisabled = true;
    UpdatesSuppressed = true;
    UserFeedbackAllowed = false;
    BraveDeAmpEnabled = true;
    BraveDebouncingEnabled = true;
    BraveReduceLanguageEnabled = true;
    DefaultBraveFingerprintingV2Setting = 3;
  };

  restoreScript = pkgs.writeShellScript "restore-brave-policy" ''
    set -euo pipefail
    src="${bravePolicyPlist}"
    target="/Library/Managed Preferences/com.brave.Browser.plist"
    [ -f "$target" ] && /usr/bin/cmp -s "$src" "$target" && exit 0
    /usr/bin/install -d -m 0755 "/Library/Managed Preferences"
    /usr/bin/install -m 0644 "$src" "$target"
  '';
in
{
  # stamp once on switch
  system.activationScripts.bravePolicy.text = ''
    ${restoreScript}
  '';

  # keep it stamped (survives regen/wipes)
  launchd.daemons.brave-policy-restore = {
    serviceConfig = {
      Label = "org.nix.brave-policy-restore";
      ProgramArguments = [ "${restoreScript}" ];
      RunAtLoad = true;
      WatchPaths = [ "/Library/Managed Preferences" ];
    };
  };
}
