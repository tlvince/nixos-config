{ pkgs, ... }:
let
  # TODO: Add vim-waikiki to nixpkgs
  # Issue URL: https://github.com/tlvince/nixos-config/issues/410
  # labels: module:neovim
  waikiki = pkgs.vimUtils.buildVimPlugin {
    name = "vim-waikiki";
    src = pkgs.fetchFromGitHub {
      hash = "sha256-8zMKrmCV4Erp0Q4WyuqyyKgZS5JGu1dXSzrhftdmNFE=";
      owner = "fcpg";
      repo = "vim-waikiki";
      rev = "7af1879a8ea0e4a0a7bd181ed17ad3d37478215e";
    };
  };
in
{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        autocomplete.blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
          setupOpts.keymap.preset = "default";
          sourcePlugins.emoji.enable = true;
        };
        autopairs.nvim-autopairs.enable = true;
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };
        fzf-lua = {
          enable = true;
          profile = "fzf-vim";
          setupOpts = {
            # TODO: fzf-lua files picker does not work with git ls-files
            # Issue URL: https://github.com/tlvince/nixos-config/issues/416
            # Set by programs.fzf.defaultCommand (FZF_DEFAULT_COMMAND)
            # repro: ``:lua FzfLua.files({ cmd = "git ls-files" })``
            # Workaround with fallback to fzf-lua default (fd)
            # labels: module:neovim
            files.cmd = "";
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
          # TODO: module 'nvim-treesitter.configs' not found
          # See https://github.com/NotAShelf/nvf/issues/1312
          # labels: module:neovim
          enableTreesitter = false;

          # TODO: Restore astro and hcl language servers
          # Issue URL: https://github.com/tlvince/nixos-config/issues/409
          # labels: module:neovim
          # astro = {
          #   enable = true;
          #   format.type = [ "prettierd" ];
          # };
          # hcl.enable = true;

          bash.enable = true;
          css = {
            enable = true;
            format.type = [ "prettierd" ];
          };
          json.enable = true;
          markdown = {
            enable = true;
            format.type = [ "prettierd" ];
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
          softtabstop = 2;
          spelllang = "en_gb";
          tabstop = 2;
          wrap = false;
        };
        searchCase = "smart";
        startPlugins = with pkgs.vimPlugins; [
          vim-vinegar
          waikiki
        ];
        theme = {
          enable = true;
          name = "onedark";
          style = "dark";
        };
        treesitter = {
          autotagHtml = true;
          enable = false;
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
