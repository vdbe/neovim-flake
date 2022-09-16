{
  description = "My neovim flake configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lualine = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };

    gruvbox = { url = "github:ellisonleao/gruvbox.nvim"; flake = false; };

    # lsp
    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    lspsaga = { url = "github:tami5/lspsaga.nvim"; flake = false; };
    lspkind = { url = "github:onsails/lspkind-nvim"; flake = false; };
    trouble = { url = "github:folke/trouble.nvim"; flake = false; };
    rnix-lsp = { url = "github:nix-community/rnix-lsp"; };
    nvim-code-action-menu = { url = "github:weilbith/nvim-code-action-menu"; flake = false; };
    lsp-signature = { url = "github:ray-x/lsp_signature.nvim"; flake = false; };
    null-ls = { url = "github:jose-elias-alvarez/null-ls.nvim"; flake = false; };
    sqls-nvim = { url = "github:nanotee/sqls.nvim"; flake = false; };
    rust-tools = { url = "github:simrat39/rust-tools.nvim"; flake = false; };
    crates-nvim = { url = "github:Saecki/crates.nvim"; flake = false; };

    # tree sitter
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
    nvim-treesitter-context = { url = "github:nvim-treesitter/nvim-treesitter-context"; flake = false; };

    # Telescope
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };

    # Autocompletes
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
    cmp-treesitter = { url = "github:ray-x/cmp-treesitter"; flake = false; };

    # Snippets
    luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };
    cmp_luasnip = { url = "github:saadparwaiz1/cmp_luasnip"; flake = false; };

    # Autopairs
    nvim-autopairs = { url = "github:windwp/nvim-autopairs"; flake = false; };
    nvim-ts-autotag = { url = "github:windwp/nvim-ts-autotag"; flake = false; };

    # Plenary (required by crates-nvim)
    plenary-nvim = { url = "github:nvim-lua/plenary.nvim"; flake = false; };

  };

  outputs = { self, nixpkgs, neovim, rnix-lsp, ... } @ inputs:
    let
      plugins = [
        "lualine"
        "gruvbox"

        "nvim-lspconfig"
        "lspsaga"
        "lspkind"
        "trouble"
        "nvim-lightbulb"
        "lsp-signature"
        "null-ls"
        "sqls-nvim"
        "rust-tools"
        "rnix-lsp"
        "nvim-code-action-menu"
        "crates-nvim"

        "nvim-cmp"
        "cmp-nvim-lsp"
        "cmp-buffer"
        "cmp-vsnip"
        "cmp-path"
        "cmp-treesitter"

        "nvim-treesitter"
        "nvim-ts-autotag"
        "nvim-treesitter-context"

        "luasnip"
        "cmp_luasnip"

        "nvim-autopairs"
        "nvim-ts-autotag"

        "telescope"

        "plenary-nvim"
      ];

      externalBitsOverlay = top: last: {
        rnix-lsp = rnix-lsp.defaultPackage.${top.system};
        neovim-nightly = neovim.defaultPackage.${top.system};
      };

      pluginOverlay = top: last:
        let
          buildPlug = name: top.vimUtils.buildVimPluginFrom2Nix {
            pname = name;
            version = "master";
            src = builtins.getAttr name inputs;
          };

        in
        {
          neovimPlugins = builtins.listToAttrs (map (name: { inherit name; value = buildPlug name; }) plugins);
        };

      allPkgs = lib.mkPkgs {
        inherit nixpkgs;
        cfg = { };
        overlays = [
          pluginOverlay
          externalBitsOverlay
        ];
      };

      lib = import ./lib;

      mkNeoVimPkg = pkgs: lib.neovimBuilder {
        inherit pkgs;
        config = {
          vim = {
            # core
            viAlias = true;
            vimAlias = true;
            configRC = "";
            startLuaConfigRC = "";
            luaConfigRC = "";
            #startPlugins = [];
            #optPlugins = [];
            #globals = [];
            #nnoremap = [];
            #inoremap = [];
            #vnoremap = [];
            #xnoremap = [];
            #snoremap = [];
            #cnoremap = [];
            #onoremap = [];
            #tnoremap = [];
            #nmap = [];
            #imap = [];
            #vmap = [];
            #xmap = [];
            #smap = [];
            #cmap = [];
            #omap = [];
            #tmap = [];

            # basic
            background = "dark";
            colorTerm = true;
            colorColumn = "+0";
            disableArrows = true;
            hideSearchHighlight = true;
            scrollOffset = 5;
            wordWrap = true;
            syntaxHighlighting = true;
            mapLeaderSpace = true;
            useSystemClipboard = false;
            mouseSupport = "a";
            lineNumberMode = "relNumber";
            preventJunkFiles = false;
            tabWidth = 2;
            autoIndent = true;
            cmdHeight = 2;
            updateTime = 300;
            showSignColumn = true;
            bell = "none";
            mapTimeout = 500;
            splitBelow = true;
            splitRight = true;
            textWidth = 0;

            statusline = {
              lualine = {
                enable = true;
                theme = "auto";
              };
            };

            treesitter = {
              enable = true;
              autotagHtml = true;
              context = {
                enable = true;
              };
              grammars = [
                (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [
                  plugins.tree-sitter-c
                  plugins.tree-sitter-nix
                  plugins.tree-sitter-python
                  plugins.tree-sitter-rust
                  plugins.tree-sitter-markdown
                  plugins.tree-sitter-comment
                  plugins.tree-sitter-toml
                  plugins.tree-sitter-make
                  plugins.tree-sitter-tsx
                  plugins.tree-sitter-html
                  plugins.tree-sitter-javascript
                  plugins.tree-sitter-css
                  plugins.tree-sitter-graphql
                  plugins.tree-sitter-json
                ]))
              ];
            };

            theme = {
              gruvbox = {
                enable = true;
              };
            };

            lsp = {
              enable = true;
              lspSignature = {
                enable = true;
              };
              nix = true;
              rust = {
                enable = true;
              };
            };

            autocomplete = {
              enable = true;
            };

            autopairs = {
              enable = true;
            };

            telescope = {
              enable = true;
            };
          };
        };
      };

    in
    {

      apps = lib.withDefaultSystems (sys:
        rec {
          nvim = {
            type = "app";
            program = "${self.defaultPackage."${sys}"}/bin/nvim";
          };

          default = nvim;
        });


      defaultPackage = lib.withDefaultSystems (sys: self.packages."${sys}".neovimEVDB);

      packages = lib.withDefaultSystems (sys: {
        neovimEVDB = mkNeoVimPkg allPkgs."${sys}";
      });
    };
}
