{ agent-sandbox, pkgs }:
let
  asLib = agent-sandbox.lib.${pkgs.system};
in
asLib.mkSandbox {
  pkg = pkgs.pi-coding-agent;
  binName = "pi";
  outName = "pi-coding-agent";
  allowedPackages = asLib.commonTools ++ [
    pkgs.fd
    pkgs.ripgrep
  ];
  rwDirs = [ "$HOME/.config/pi" ];
  env = {
    PI_CODING_AGENT_DIR = "$HOME/.config/pi";
    PI_OFFLINE = "true";
  };
}
