let
  keys = import ../keys.nix;
in
  with keys; {
    "dns.age".publicKeys = [
      tlv
      cm3588
    ];
  }

