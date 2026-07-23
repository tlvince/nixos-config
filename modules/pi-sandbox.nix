{ agent-sandbox, pkgs }:
let
  sandbox = agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system};
in
sandbox.mkSandbox {
  pkg = pkgs.pi-coding-agent;
  binName = "pi";
  outName = "pi";
  allowedPackages = sandbox.commonTools;
  rwDirs = [ "$HOME/.config/pi" ];
  env = {
    PI_CODING_AGENT_DIR = "$HOME/.config/pi";
    PI_OFFLINE = "true";
  };
}
