{
  config,
  lib,
  pkgs,
  tmux-colours-onedark,
  ...
}: {
  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${config.xdg.dataHome}/backgrounds/ChromeOSWind-1.png";
      picture-uri-dark = "file://${config.xdg.dataHome}/backgrounds/ChromeOSWind-2.png";
      primary-color = "#3465a4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
      ];
      xkb-options = [
        "caps:escape"
      ];
    };
    "org/gnome/desktop/interface" = {
      document-font-name = "Sans 11";
      enable-animations = false;
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      font-hinting = "none";
      font-name = "Sans 11";
      monospace-font-name = "Monospace 12.5";
      show-battery-percentage = true;
    };
    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };
    "org/gnome/desktop/session" = {
      idle-delay = 120;
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Sans Bold 11";
    };
    "org/gnome/mutter" = {
      experimental-features = [
        "variable-refresh-rate"
      ];
    };
    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
      power-button-action = "suspend";
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "suspend";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "light-style@gnome-shell-extensions.gcampax.github.com"
        "nightthemeswitcher@romainvigier.fr"
      ];
      favorite-apps = [
        "firefox.desktop"
        "foot.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Evolution.desktop"
        "org.gnome.Calendar.desktop"
      ];
    };
  };

  home = {
    homeDirectory = "/home/tlv";
    file = {
      ".digrc".text = "+noall +answer";
      "${config.xdg.dataHome}/backgrounds/ChromeOSWind-1.png".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/refs/heads/main/Dynamic_Wallpapers/ChromeOSWind/ChromeOSWind-1.png";
        hash = "sha256-lT6dvLymLtlJ+xFFyX7k1aV0lTBceZXRJSeCQvJqA3o=";
      };
      "${config.xdg.dataHome}/backgrounds/ChromeOSWind-2.png".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/refs/heads/main/Dynamic_Wallpapers/ChromeOSWind/ChromeOSWind-2.png";
        hash = "sha256-jB0T07ro1QtJ6fYcu/IKHZB8ESNbqwpVHtA9nr8alUg=";
      };
    };
    sessionVariables = {
      # Zsh's "< file" built-in pager
      READNULLCMD = "$PAGER";
      LESS = "--chop-long-lines --ignore-case --LONG-PROMPT --no-init --RAW-CONTROL-CHARS --quit-if-one-screen --quit-on-intr";
      SYSTEMD_LESS = "$LESS";

      # Default to Wayland for Chrome/Electron
      # https://nixos.org/manual/nixos/unstable/release-notes#sec-release-23.11
      NIXOS_OZONE_WL = 1;

      # https://github.com/agkozak/zsh-z/tree/afaf2965b41fdc6ca66066e09382726aa0b6aa04#settings
      ZSHZ_CMD = "j";

      # https://telemetry.timseverien.com/opt-out/
      # https://github.com/jeremy-code/dotfiles/blob/22979c1132b33c39fe59a07a2d865b0121cc2c6b/oh-my-zsh/telemetry.zsh
      ALGOLIA_CLI_TELEMETRY = 0; # Algolia
      AMPLIFY_DISABLE_TELEMETRY = 1; # AWS Amplify
      APOLLO_TELEMETRY_DISABLED = 1; # Apollo Router/Rover
      ARDUINO_METRICS_ENABLED = "false"; # Arduino
      ASTRO_TELEMETRY_DISABLED = 1; # Astro
      AZURE_CORE_COLLECT_TELEMETRY = 0; # Azure
      CALCOM_TELEMTRY_DISABLED = 1; # Cal.com
      CHECKPOINT_DISABLE = 1; # Prisma, Terraform
      CLOUDSDK_CORE_DISABLE_USAGE_REPORTING = "true"; # Google Cloud SDK
      DATAHUB_TELEMETRY_ENABLED = "false"; # DataHub
      DA_TEST_DISABLE_TELEMETRY = 1; # JavaScript Debugger (VSCode)
      DDB_LOCAL_TELEMETRY = 0; # DynamoDB
      DISABLE_ZAPIER_ANALYTICS = 1; # Zapier
      DOTNET_CLI_TELEMETRY_OPTOUT = 1; # .NET
      DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT = 1; # .NET Interactive
      DO_NOT_TRACK = 1; # https://consoledonottrack.com
      EXPO_NO_TELEMETRY = 1; # Expo
      GATSBY_TELEMETRY_DISABLED = 1; # Gatsby
      GOTELEMETRY = "false"; # Go
      HASURA_GRAPHQL_ENABLE_TELEMETRY = "false"; # Hasura
      HOMEBREW_NO_ANALYTICS = 1;
      MSSQL_TELEMETRY_ENABLED = "false"; # Azure SQL Edge
      NEXT_TELEMETRY_DISABLED = 1; # Next.js
      NG_CLI_ANALYTICS = "false"; # Angular CLI
      NUXT_TELEMETRY_DISABLED = 1; # Nuxt.js
      SAM_CLI_TELEMETRY = 0; # AWS SAM
      SFDX_DISABLE_TELEMETRY = "true"; # Salesforce CLI
      SLS_TELEMETRY_DISABLED = 1; # Serverless Framework
      SST_TELEMETRY_DISABLED = 1; # SST
      STORYBOOK_DISABLE_TELEMETRY = 1; # Storybook
      STRAPI_TELEMETRY_DISABLED = "true";
      STRIPE_CLI_TELEMETRY_OPTOUT = 1; # Stripe
      TELEMETRY_DISABLED = 1;
      YARN_ENABLE_TELEMETRY = 0; # Yarn

      # https://github.com/sindresorhus/pure/tree/87e6f5dd4c793f6d980532205aaefe196780606f#options
      PURE_GIT_PULL = 0;

      # https://typicode.github.io/husky/get-started.html#disabling-hooks
      HUSKY = 0;

      # XDG
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      GOCACHE = "$XDG_CACHE_HOME/go/build";
      GOMODCACHE = "$XDG_CACHE_HOME/go/mod";
      NODE_REPL_HISTORY = "$XDG_DATA_HOME/node_repl_history";
      NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    };
    stateVersion = "23.05";
    username = "tlv";
  };

  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };

  # TODO: GC does not clean up user profiles when ran as root
  # Remove when https://github.com/NixOS/nix/issues/8508 is resolved
  # labels: home-manager
  # Issue URL: https://github.com/tlvince/nixos-config/issues/302
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "1 hour";
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=12.5";
        include = "${pkgs.foot.themes}/share/foot/themes/onedark";
        initial-window-mode = "fullscreen";
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
    changeDirWidgetCommand = "(git ls-tree -d -r --name-only HEAD || fd --type directory) 2>/dev/null";
    defaultCommand = "(git ls-files --cached --exclude-standard --others || fd --type file) 2>/dev/null";
    defaultOptions = [
      "--cycle"
      "--no-mouse"
    ];
    fileWidgetCommand = "(git ls-files --cached --exclude-standard --others || fd --type file) 2>/dev/null";
  };

  programs.git = {
    enable = true;
    settings = {
      alias = {
        br = "branch";
        brrm = "!git branch | grep -vE '^\\*|main|master' | xargs -n 1 git branch -D";
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
        pd = "pull --rebase --tags";
        pu = "push --tags";
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
      user = {
        email = "git@tlvince.com";
        name = "Tom Vincent";
      };
      web = {
        browser = "gio open";
      };
    };
    attributes = [
      "* text=auto"
    ];
    signing = {
      key = "AB184CDBE6AEACDE";
      signByDefault = true;
    };
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
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.home-manager.enable = true;

  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = 1;
      highlight_base_name = 1;
      screen_tabs = 1;
      shadow_other_users = 1;
      show_cpu_frequency = 1;
      show_program_path = 0;
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "dmabuf-wayland";
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

  programs.readline = {
    enable = true;

    bindings = {
      "\e[3;3~" = "kill-word";
    };

    extraConfig = ''
      # History with up/down keys
      $if mode=vi
        set keymap vi-command
        "\e[A": history-search-backward
        "\e[B": history-search-forward
        set keymap vi-insert
        "\e[A": history-search-backward
        "\e[B": history-search-forward
        "\C-l": clear-screen
      $else
        "\e[A": history-search-backward
        "\e[B": history-search-forward
      $endif
    '';

    # https://github.com/tlvince/shell-config/blob/9498a951e5ed612f106b4ae53c579fe2c9ce2a8c/.inputrc
    variables = {
      # Make Tab autocomplete regardless of filename case
      completion-ignore-case = true;
      # If there are more than 200 possible completions for a word, ask to show them all
      completion-query-items = 200;
      editing-mode = "vi";
      # Immediately add a trailing slash when autocompleting symlinks to directories
      mark-symlinked-directories = true;
      # Do not autocomplete hidden files unless the pattern explicitly begins with a dot
      match-hidden-files = false;
      # Show all autocomplete results at once
      page-completions = false;
      # List all matches in case multiple possible completions are possible
      show-all-if-ambiguous = true;
      # Be more intelligent when autocompleting
      skip-completed-text = true;
      # Show extra file information when completing, like `ls -F` does
      visible-stats = true;

      # # Allow UTF-8 input and output
      convert-meta = false;
      input-meta = true;
      output-meta = true;
    };
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    extraConfig = ''
      # Toggle the last window with prefix
      bind-key C-a last-window

      # Open new windows/splits in an interactive shell, not login shell (by default)
      set-option -g default-command "$SHELL"

      # Intuitive window-splitting keys
      bind '"' split-window -c "#{pane_current_path}"
      bind - split-window -vc "#{pane_current_path}"
      bind % split-window -hc "#{pane_current_path}"
      bind '\' split-window -hc "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Set window name based on command
      set-window-option -g automatic-rename on

      # Reload config
      bind r source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"\; display-message "Config reloaded..."

      # Copy/paste to/from the system clipboard
      unbind [
      bind Escape copy-mode
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy && wl-paste -n | wl-copy -p"
      bind-key p run "wl-paste -n | tmux load-buffer - ; tmux paste-buffer"

      # Disable noisy right-hand status bar
      set-option -g status-right ""

      # Toggle the status bar
      bind-key b set-option -g status

      # Zoom split
      bind-key | resize-pane -Z

      # Colours
      set-option -ga terminal-overrides ",tmux-256color:Tc,xterm-256color:Tc"
      ${pkgs.lib.fileContents "${tmux-colours-onedark}/tmux-colours-onedark.conf"}
    '';
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    secureSocket = true;
    sensibleOnTop = false;
    terminal = "screen-256color";
  };

  programs.zsh = {
    enable = true;

    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    history.ignoreAllDups = true;

    initContent =
      ''
        # Prompt
        autoload -U promptinit; promptinit
        prompt pure

        # Autojump
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

        # Escape URLs when pasting
        autoload -Uz bracketed-paste-magic url-quote-magic
        zle -N bracketed-paste bracketed-paste-magic
        zle -N self-insert url-quote-magic

        # History search matching the current line up to the current cursor position
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
        bindkey "$terminfo[kcud1]" down-line-or-beginning-search

        # Fix pasting with autosuggest
        # https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
        pasteinit() {
          OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
          zle -N self-insert url-quote-magic
        }
        pastefinish() {
          zle -N self-insert $OLD_SELF_INSERT
        }
        zstyle :bracketed-paste-magic paste-init pasteinit
        zstyle :bracketed-paste-magic paste-finish pastefinish

        # Write history immediately, rather than on shell exit
        setopt INC_APPEND_HISTORY

        # Spell check
        setopt CORRECT

        # Glob
        setopt EXTENDED_GLOB
        setopt GLOB_COMPLETE
        setopt COMPLETE_IN_WORD
        setopt NUMERIC_GLOB_SORT

        # Sanity checks
        setopt NO_CLOBBER
        setopt RM_STAR_WAIT

        # Array expansion
        setopt RC_EXPAND_PARAM

        # <Ctrl + e>: Invoke a visual editor on the command line
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey "^e" edit-command-line

        # <Alt + .>: Insert the last argument of the previous command
        bindkey "^[." insert-last-word

        # Shift-Tab
        bindkey "^[[Z" reverse-menu-complete

        # Tab Completion options <http://stackoverflow.com/a/171564>
        zstyle ':completion::complete:*' use-cache on
        zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zcompcache"

        # case insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

        zstyle ':completion:*' verbose yes
        zstyle ':completion:*:descriptions' format '%B%d%b'
        zstyle ':completion:*:messages' format '%d'
        zstyle ':completion:*:warnings' format 'No matches for: %d'
        zstyle ':completion:*' group-name \'\'
        zstyle ':completion:*' completer _expand _complete _approximate _ignored

        # generate descriptions with magic.
        zstyle ':completion:*' auto-description 'specify: %d'

        # Don't prompt for a huge list, page it!
        zstyle ':completion:*:default' list-prompt '%S%M matches%s'

        # Don't prompt for a huge list, menu it!
        zstyle ':completion:*:default' menu 'select=0'

        # Have the newer files last so I see them first
        zstyle ':completion:*' file-sort modification reverse

        # color code completion!!!!  Wohoo!
        zstyle ':completion:*' list-colors "=(#b) #([0-9]#)*=36=31"

        # Separate man page sections.  Neat.
        zstyle ':completion:*:manuals' separate-sections true

        # complete with a menu for xwindow ids
        zstyle ':completion:*:windows' menu on=0
        zstyle ':completion:*:expand:*' tag-order all-expansions

        # more errors allowed for large words and fewer for small words
        zstyle ':completion:*:approximate:*' max-errors 'reply=(  $((  ($#PREFIX+$#SUFFIX)/3  ))  )'

        # Errors format
        zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'

        # Don't complete stuff already on the line
        zstyle ':completion::*:(rm|vi):*' ignore-line true

        # Don't complete directory we are already in (../here)
        zstyle ':completion:*' ignore-parents parent pwd

        zstyle ':completion::approximate*:*' prefix-needed false
      ''
      + builtins.readFile ./functions.zsh;

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
      curl-time = "curl --output /dev/null --silent --write-out 'DNS: %{time_namelookup}s\nEstablish Connection: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n'";
      ll = "l | less";
      mk = "mkdir -p";
      mpva = "mpv --no-video";
      mpvn = "mpv --no-ytdl";
      myip = "curl --silent https://ifconfig.me";
      nd = "nix develop --command $SHELL";
      pc = "pass -c";
      pct = "passCopyTail";
      pg = "passGenerate";
      po = "popd";
      pu = "pushd";
      rd = "rmdir";
      serve = "python3 -m http.server --bind 127.0.0.1";
      sudu = "sudo -iu";
      ts = "date --utc +'%Y-%m-%dT%H:%M:%S.%3NZ'";
      th = "dict -d moby-thesaurus";
      webcam = "mpv --demuxer-lavf-format=video4linux2 --demuxer-lavf-o=video_size=1920x1080,input_format=mjpeg av://v4l2:/dev/video0 --profile=low-latency --untimed --vf=hflip";

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

    syntaxHighlighting.enable = true;
  };

  wayland.windowManager.sway = {
    enable = false;

    config = {
      input = {
        "type:keyboard" = {
          xkb_options = "caps:escape";
        };
        "type:pointer" = {
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      menu = "${pkgs.bemenu}/bin/bemenu-run";
      modifier = "Mod4";
      terminal = "${pkgs.foot}/bin/foot --config $XDG_CONFIG_HOME/foot/foot-windowed.ini";
    };

    package = null;
    xwayland = false;
  };

  xdg = {
    enable = true;

    # Stream audio to an AirPlay receiver
    # https://wiki.archlinux.org/index.php?title=PipeWire&oldid=792188#Streaming_audio_to_an_AirPlay_receiver
    configFile."pipewire/pipewire.conf.d/raop-discover.conf".text = ''
      context.modules = [
        {
          name = libpipewire-module-raop-discover
          args = {}
        }
      ]
    '';

    configFile."systemd/user/org.gnome.Shell@wayland.service.d/override.conf".text = ''
      [Service]
      ExecStart=
      ExecStart=${pkgs.gnome-shell}/bin/gnome-shell --no-x11
    '';

    userDirs = {
      enable = true;

      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };
  };
}
