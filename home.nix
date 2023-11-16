{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:escape" ];
    };
    "org/gnome/desktop/interface" = {
      font-hinting = "none";
      font-antialiasing = "greyscale";
    };
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  home = {
    homeDirectory = "/home/tlv";
    sessionVariables = {
      # Default to Wayland for Chrome/Electron
      # https://nixos.org/manual/nixos/unstable/release-notes#sec-release-23.11
      NIXOS_OZONE_WL = 1;

      # https://github.com/agkozak/zsh-z/tree/afaf2965b41fdc6ca66066e09382726aa0b6aa04#settings
      ZSHZ_CMD = "j";

      # https://telemetry.timseverien.com/opt-out/
      # https://consoledonottrack.com/
      ASTRO_TELEMETRY_DISABLED = 1;
      AZURE_CORE_COLLECT_TELEMETRY = 0;
      DISABLE_ZAPIER_ANALYTICS = 1;
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;
      GATSBY_TELEMETRY_DISABLED = 1;
      HOMEBREW_NO_ANALYTICS = 1;
      NEXT_TELEMETRY_DISABLED = 1;
      SAM_CLI_TELEMETRY = 0;
      TELEMETRY_DISABLED = 1;

      # Workaround a GNOME bug for foot, see:
      # https://codeberg.org/dnkl/foot/issues/1426
      XCURSOR_SIZE = 16;
      XCURSOR_THEME = "Adwaita";

      # https://github.com/sindresorhus/pure/tree/87e6f5dd4c793f6d980532205aaefe196780606f#options
      PURE_GIT_PULL = 0;
    };
    stateVersion = "23.05";
    username = "tlv";
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "dom.security.https_only_mode" = true;
        "extensions.pocket.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "ui.key.menuAccessKeyFocuses" = false;
      };
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
        #initial-window-mode = "fullscreen";
      };
      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1;
      };
      scrollback = {
        lines = 10000;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # https://github.com/junegunn/fzf/blob/7320b7df62039c879c4f609bca946ea09b438a98/shell/key-bindings.zsh#L76
    changeDirWidgetCommand = "(git ls-tree -d -r --name-only HEAD || fd --type directory || command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -type d -print 2> /dev/null | cut -b3-) 2>/dev/null";
    # https://github.com/junegunn/fzf/blob/7320b7df62039c879c4f609bca946ea09b438a98/src/constants.go#L61
    defaultCommand = "(git ls-files --cached --exclude-standard --others || fd --type file || command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -type f -print -o -type l -print 2>/dev/null | cut -b3-) 2>/dev/null";
    defaultOptions = [
      "--cycle"
      "--no-mouse"
    ];
    # https://github.com/junegunn/fzf/blob/7320b7df62039c879c4f609bca946ea09b438a98/shell/key-bindings.zsh#L44C5-L47C47
    fileWidgetCommand = "(git ls-files --cached --exclude-standard --others || fd --type file || command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -type f -print -o -type l -print 2>/dev/null | cut -b3-) 2>/dev/null";
  };

  programs.git = {
    enable = true;
    aliases = {
      br = "branch";
      brrm = "!git branch | grep -v '^*' | grep -v 'master' | xargs -n 1 git branch -D";
      c = "commit";
      cfa = "commit --all --amend --no-edit";
      ci = "commit --all";
      cia = "commit --all --message";
      cl = "clone --recursive";
      co = "checkout";
      cob = "checkout -b";
      com = "checkout master";
      cp = "cherry-pick";
      cpc = "cherry-pick --continue";
      d = "diff";
      dfs = "diff --stat";
      g = "grep --ignore-case";
      l = "log -p --follow";
      lh = "log --follow --pretty=format:'%H'";
      lhr = "log --reverse --pretty=format:'%H'";
      lm = "log --follow --pretty=format:'%s'";
      lo = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lpp = "log --graph --all --pretty=format:'%h by %an (%cr):%d %s' --abbrev-commit --decorate --date-order";
      ls = "ls-files";
      mt = "mergetool";
      pa = "push --all all";
      pd = "pull --rebase --tags origin master";
      pdd = "pull --rebase --tags origin develop";
      pud = "push --tags --set-upstream develop";
      put = "push --tags --set-upstream tlvince";
      puu = "push --tags --set-upstream origin";
      rbc = "rebase --continue";
      s = "status --short --ignore-submodules=dirty";
      subpd = "submodule foreach --recursive git pull origin master";
      subpu = "submodule foreach --recursive git push origin master";
      # Overrides
      ctags = "!.git/hooks/ctags";
      # Show verbose output about tags, branches or remotes";
      branches = "branch -a";
      remotes = "remote -v";
      tags = "tag -l";
    };
    attributes = [
      "* text=auto"
    ];
    diff-so-fancy.enable = true;
    extraConfig = {
      apply = {
        whitespace = "fix";
      };
      branch = {
        autosetuprebase = "always";
      };
      color = {
        ui = "auto";
      };
      "color \"grep\"" = {
        match = "green";
      };
      commit = {
        verbose = true;
      };
      core = {
        whitespace = "space-before-tab,trailing-space";
        untrackedCache = true;
      };
      diff = {
        compactionHeuristic = true;
        tool = "nvim -d";
      };
      difftool = {
        prompt = false;
      };
      github = {
        user = "tlvince";
      };
      merge = {
        tool = "fugitive";
      };
      mergetool = {
        keepBackup = false;
        prompt = false;
      };
      "mergetool \"fugitive\"" = {
        cmd = "nvim -c Gdiff $MERGED";
      };
      push = {
        default = "simple";
      };
      web = {
        browser = "gio open";
      };
    };
    signing = {
      key = "AB184CDBE6AEACDE";
      signByDefault = true;
    };
    userEmail = "git@tlvince.com";
    userName = "Tom Vincent";
  };

  programs.gpg = {
    enable = true;
    settings = {
      default-key = "E6AEACDE";
      default-recipient-self = true;
      keyserver = "hkp://keys.gnupg.net";
      keyserver-options = "auto-key-retrieve";
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    defaultCacheTtl = 28800; # 8 hours
    defaultCacheTtlSsh = 28800; # 8 hours
    maxCacheTtl = 57600; # 16 hours
    maxCacheTtlSsh = 57600; # 16 hours
    pinentryFlavor = "gnome3";
  };

  programs.home-manager.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      ytdl-format = "(bestvideo[vcodec^=av01][height<=?2160]/bestvideo[height<=?2160])+bestaudio/best";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.zsh = {
    enable = true;

    shellAliases = {
      # Overrides
      ag = "ag --pager less --smart-case";
      df = "df -h";
      diff = "diff --color=auto --unified";
      du = "du -hc";
      grep = "grep --color=auto";
      htop = "htop -u $USER";
      ls = "ls --color=auto --human-readable --no-group";
      mysql = "mysql --pager=\"less -nSFX\"";
      vi = "nvim";
      visudo = "sudo EDITOR=nvim visudo";

      # Shortcuts
      ".." = "cd ..";
      "..." = "cd ../..";
      acp = "rsync -a --partial-dir=\".rsync-partial\" --progress";
      adbss = "adb shell screencap -p > /tmp/android-screenshot-\$(date +%s).png";
      ll = "l | less";
      mk = "mkdir -p";
      mpva = "mpv --no-video";
      mpvn = "mpv --no-ytdl";
      myip = "curl --silent https://ifconfig.me";
      pc = "pass -c";
      pct = "passCopyTail";
      pg = "passGenerate";
      po = "popd";
      pu = "pushd";
      radio6 = "get_iplayer --type liveradio --stream 80102 | $PLAYER -";
      rd = "rmdir";
      serve = "python3 -m http.server";
      sudu = "sudo -iu";
      th = "dict -d moby-thesaurus";
      webcam = "mpv --demuxer-lavf-format=video4linux2 --demuxer-lavf-o=video_size=1920x1080,input_format=mjpeg av://v4l2:/dev/video0";

      # Compression
      "7z9" = "7z a -mx9 -mmt -ms";
      "7zp" = "7z9 -mhe";
      "7zt" = "7z a -m0=PPMd -ms";

      # Single character
      b = "bookmark";
      c = "wl-copy";
      d = "dict -d wn";
      g = "git";
      # j reserved for zsh-z
      l = "ls -lA";
      o = "gio open";
      p = "wl-paste";
      s = "spell";
      v = "nvim";
    };

    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
    autoload -U promptinit; promptinit
    prompt pure

    source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
    '';
  };
}
