{ pkgs, ... }:
{
  notify = pkgs.writeScriptBin "notify" ''
    ${pkgs.curl}/bin/curl -H "Authorization: Bearer $(<"$CREDENTIALS_DIRECTORY/notify")" --silent --output /dev/null \
      --json '{"title": "'"$TITLE"'", "message": "'"$MESSAGE"'"}' \
      "https://home-assistant.filo.uk/api/services/notify/mobile_app_pixel"
  '';
}
