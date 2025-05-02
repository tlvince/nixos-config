let
  keys = import ../keys.nix;
in
  with keys; {
    "dns.age".publicKeys = [
      cm3588
      tlv
    ];

    "notify.age".publicKeys = [
      cm3588
      framework
    ];

    "radicale.age".publicKeys = [
      cm3588
    ];
  }
