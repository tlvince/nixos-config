final: prev: {
  evolution-ews = prev.evolution-ews.overrideAttrs (_: rec {
    version = "3.58.1";
    src = final.fetchurl {
      url = "mirror://gnome/sources/evolution-ews/${final.lib.versions.majorMinor version}/evolution-ews-${version}.tar.xz";
      hash = "sha256-EABr14/7fWQJxdAKVYvp3BkOhZS7miuXPi7AVhMWeCA=";
    };
  });
}
