{
  config,
  pkgs,
  ...
}: {
  notify = pkgs.writeScriptBin "notify" ''
    DEVICE="mobile_app_pixel_7a"
    ${pkgs.jq}/bin/jq --null-input --arg title "$TITLE" --arg message "$MESSAGE" '{"title": $title, "message": $message}' | \
    ${pkgs.curl}/bin/curl -H "Authorization: $(<${config.age.secrets.notify.path})" --silent --output /dev/null --json @- \
    "https://home-assistant.filo.uk/api/services/notify/$DEVICE"
  '';
}
