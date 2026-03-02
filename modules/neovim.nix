{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (_final: prev: {
      markdown-oxide = prev.markdown-oxide.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # TODO: Drop markdown-oxide workspace symbols patch
          # https://github.com/Feel-ix-343/markdown-oxide/pull/345
          # labels: neovim
          (prev.fetchpatch {
            url = "https://github.com/tlvince/markdown-oxide/commit/46b0a90c21f178bc7afbc64fba5a4281c6795fdb.patch";
            hash = "sha256-loOgqY6P507LJgVWQZboxCBf/uZn7GXW0g/24lDPpVY=";
          })
        ];
      });
    })
  ];

  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings = {
      vim = {
        autocomplete.blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
          setupOpts = {
            cmdline.keymap.preset = "inherit";
            keymap.preset = "default";
          };
          sourcePlugins.emoji.enable = true;
        };
        autopairs.nvim-autopairs.enable = true;
        autocmds = [
          {
            event = [ "QuickFixCmdPost" ];
            pattern = [ "[^l]*" ];
            command = "cwindow";
            nested = true;
            desc = "Open quickfix window after quickfix command";
          }
          {
            event = [ "QuickFixCmdPost" ];
            pattern = [ "l*" ];
            command = "lwindow";
            nested = true;
            desc = "Open location list window after location list command";
          }
          {
            event = [ "BufWritePost" ];
            pattern = [ "*/documents/wiki/*" ];
            command = "silent! Gwrite | silent! execute 'Git commit -m ' . shellescape('Updated ' . expand('%:.'))";
            desc = "Auto-commit on save with fugitive";
          }
          {
            event = [ "FileType" ];
            pattern = [ "markdown" ];
            callback = lib.generators.mkLuaInline ''
              function()
                  vim.opt_local.formatoptions:append("rn")

                  -- Unordered lists
                  vim.opt_local.comments = {
                    "b:- [ ]",
                    "b:- [x]",
                    "b:*",
                    "b:-",
                    "b:+",
                  }

                  local opts = { buffer = true, expr = true, silent = true, noremap = true }

                  vim.keymap.set("i", "<CR>", function()
                    local line = vim.api.nvim_get_current_line()

                    -- Empty list item
                    local indent = line:match("^(%s*)[-*+]%s*$")
                                or line:match("^(%s*)- %[ x%]%s*$")
                                or line:match("^(%s*)%d+%.%s*$")
                    if indent then
                      return "<C-U>" .. indent .. "<CR>"
                    end

                    -- Ordered lists
                    local i, num = line:match("^(%s*)(%d+)%.%s+%S")
                    if num then
                      return "<CR>" .. i .. (tonumber(num) + 1) .. ". "
                    end

                    return "<CR>"
                  end, opts)
                end
            '';
            desc = "Automated bullet lists (bullets.vim)";
          }
        ];
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };
        fzf-lua = {
          enable = true;
          profile = "fzf-vim";
          setupOpts = {
            files = {
              # FZF_DEFAULT_COMMAND prefers `git ls-files`, but FzfLua's files
              # picker adds flags unsupported by `git`, so fallback to the
              # default cmd (`fd`)
              cmd = "";
            };
            global = {
              fzf_opts = {
                # Shorter paths rank higher
                "--scheme" = "default";
              };
            };
          };
        };
        git = {
          gitsigns.enable = true;
          vim-fugitive.enable = true;
        };
        hideSearchHighlight = false;
        keymaps = [
          {
            key = "<C-p>";
            mode = "n";
            action = "<Cmd>FzfLua global<CR>";
            desc = "fzf-lua: global";
          }
          {
            key = "<C-\\>";
            mode = "n";
            action = "<Cmd>FzfLua buffers<CR>";
            desc = "fzf-lua: buffers";
          }
          {
            key = "<LocalLeader>i";
            mode = "n";
            silent = true;
            action = "<Cmd>let &l:cocu = (&l:cocu==\"\" ? \"n\" : \"\")<CR>";
            desc = "Toggle conceal cursor";
          }
          {
            key = "<LocalLeader>w<LocalLeader>w";
            mode = "n";
            silent = true;
            action = "<Cmd>execute 'edit diary/' . strftime('%Y-%m-%d') . '.md'<CR>";
            desc = "Open today's diary entry";
          }
          {
            key = "<localleader>c";
            mode = "n";
            action = "<Cmd>setlocal cursorline! cursorcolumn!<CR>";
            desc = "Toggle highlighting of current line and column";
          }
          {
            key = "<localleader>e";
            mode = "n";
            lua = true;
            action = "function() _G.open_adjacent('e') end";
            desc = "Edit adjacent file";
          }
          {
            key = "<localleader>es";
            mode = "n";
            lua = true;
            action = "function() _G.open_adjacent('sp') end";
            desc = "Split adjacent file";
          }
          {
            key = "<localleader>et";
            mode = "n";
            lua = true;
            action = "function() _G.open_adjacent('tabe') end";
            desc = "Tab adjacent file";
          }
          {
            key = "<localleader>ev";
            mode = "n";
            lua = true;
            action = "function() _G.open_adjacent('vsp') end";
            desc = "VSplit adjacent file";
          }
          {
            key = "<localleader>ga";
            mode = "n";
            silent = true;
            action = "<Cmd>Git add %:p<CR><CR>";
            desc = "Fugitive: add current file";
          }
          {
            key = "<localleader>gb";
            mode = "n";
            silent = true;
            action = "<Cmd>Git blame<CR>";
            desc = "Fugitive: blame";
          }
          {
            key = "<localleader>gb";
            mode = "x";
            silent = true;
            action = "<Cmd>Git blame<CR>";
            desc = "Fugitive: blame (visual)";
          }
          {
            key = "<localleader>gc";
            mode = "n";
            silent = true;
            action = "<Cmd>Git commit -v -q<CR>";
            desc = "Fugitive: commit";
          }
          {
            key = "<localleader>gd";
            mode = "n";
            silent = true;
            action = "<Cmd>Gdiffsplit<CR>";
            desc = "Fugitive: diff split";
          }
          {
            key = "<localleader>ge";
            mode = "n";
            silent = true;
            action = "<Cmd>Gedit<CR>";
            desc = "Fugitive: edit";
          }
          {
            key = "<localleader>gg";
            mode = "n";
            silent = true;
            action = ":Ggrep --ignore-case ";
            desc = "Fugitive: grep";
          }
          {
            key = "<localleader>gl";
            mode = "n";
            silent = true;
            action = ":silent! Gclog<CR>:bot copen<CR>";
            desc = "Fugitive: log (quickfix)";
          }
          {
            key = "<localleader>gm";
            mode = "n";
            silent = true;
            action = ":GMove ";
            desc = "Fugitive: move";
          }
          {
            key = "<localleader>go";
            mode = "n";
            silent = true;
            action = ":Git checkout ";
            desc = "Fugitive: checkout";
          }
          {
            key = "<localleader>gpd";
            mode = "n";
            silent = true;
            action = "<Cmd>Git pull<CR>";
            desc = "Fugitive: pull";
          }
          {
            key = "<localleader>gpu";
            mode = "n";
            silent = true;
            action = "<Cmd>Git push<CR>";
            desc = "Fugitive: push";
          }
          {
            key = "<localleader>gr";
            mode = "n";
            silent = true;
            action = "<Cmd>Gread<CR>";
            desc = "Fugitive: read";
          }
          {
            key = "<localleader>gs";
            mode = "n";
            silent = true;
            action = "<Cmd>Git<CR>";
            desc = "Fugitive: status";
          }
          {
            key = "<localleader>gt";
            mode = "n";
            silent = true;
            action = "<Cmd>Git commit -v -q %:p<CR>";
            desc = "Fugitive: commit current file";
          }
          {
            key = "<localleader>gw";
            mode = "n";
            silent = true;
            action = "<Cmd>Gwrite<CR><CR>";
            desc = "Fugitive: write";
          }
          {
            key = "<localleader>s";
            mode = "n";
            silent = true;
            action = "<Cmd>setlocal spell! spell?<CR>";
            desc = "Toggle spelling and show status";
          }
        ];
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          astro.enable = true;
          bash.enable = true;
          css = {
            enable = true;
            format.type = [ "prettierd" ];
          };
          json.enable = true;
          markdown = {
            enable = true;
            format.type = [ "prettierd" ];
            lsp.servers = [ "markdown-oxide" ];
          };
          nix = {
            enable = true;
            format.type = [ "nixfmt" ];
          };
          svelte.format.type = [ "prettierd" ];
          tailwind.enable = true;
          terraform.enable = true;
          ts = {
            enable = true;
            format.type = [ "prettierd" ];
          };
          yaml.enable = true;
        };
        lineNumberMode = "none";
        lsp = {
          enable = true;
          formatOnSave = true;
          mappings = {
            codeAction = "gra";
            goToDeclaration = "gD";
            goToDefinition = "gd";
            goToType = "gy";
            hover = "K";
            listDocumentSymbols = "gs";
            listImplementations = "gI";
            listReferences = "grr";
            listWorkspaceSymbols = "gS";
            nextDiagnostic = "g]";
            previousDiagnostic = "g[";
            renameSymbol = "grn";
            signatureHelp = "<C-s>";
          };
        };
        luaConfigRC = {
          # Open a file (relative to the current file)
          # See: http://vimcasts.org/episodes/the-edit-command/
          # Synonyms: {e: edit, where: {w: window, s: split, v: vertical split, t: tab}}
          adjacentEdit = ''
            _G.open_adjacent = function(cmd)
              local dir = vim.fn.expand("%:h")
              if dir == "" then dir = vim.fn.getcwd() end
              local keys = vim.api.nvim_replace_termcodes("<Esc>:" .. cmd .. " " .. dir .. "/", true, false, true)
              vim.api.nvim_feedkeys(keys, "n", false)
            end
          '';
          fugitive = ''
            vim.opt.diffopt:append("vertical")
          '';
          lsp-diagnostics = ''
            local severity = vim.diagnostic.severity
            vim.diagnostic.config({
              signs = {
                text = {
                  [severity.ERROR] = "✖",
                  [severity.WARN]  = "⚠",
                  [severity.INFO]  = "𝐢",
                  [severity.HINT]  = "•",
                },
              },
            })
          '';
          waikiki = ''
            vim.g.waikiki_wiki_patterns     = { "/wiki/", "/wiki-" }
            vim.g.waikiki_default_maps      = 1
            vim.g.waikiki_done              = "x"
            vim.g.waikiki_space_replacement = "-"
            vim.g.waikiki_index             = "README.md"
          '';
        };
        options = {
          conceallevel = 2;
          expandtab = true;
          guicursor = "";
          shiftwidth = 2;
          showcmd = false;
          softtabstop = 2;
          spelllang = "en_gb";
          tabstop = 2;
          wrap = false;
        };
        searchCase = "smart";
        startPlugins = with pkgs.vimPlugins; [
          vim-rhubarb
          vim-vinegar
          vim-waikiki
        ];
        theme = {
          enable = true;
          name = "onedark";
          style = "dark";
        };
        treesitter = {
          autotagHtml = true;
          enable = true;
          fold = true;
        };
        utility.mkdir.enable = true;
        viAlias = true;
        vimAlias = true;
        # Used by blink.cmp, fzf-lua
        visuals.nvim-web-devicons.enable = true;
        withRuby = false;
      };
    };
  };
}
