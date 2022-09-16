{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    enable = mkEnableOption "neovim lsp support";
    formatOnSave = mkEnableOption "Format on save";
    nix = mkEnableOption "Nix LSP";
    rust = {
      enable = mkEnableOption "Rust LSP";
      rustAnalyzerOpts = mkOption {
        type = types.str;
        default = ''
          ["rust-analyzer"] = {
            experimental = {
              procAttrMacros = true,
            },
          },
        '';
        description = "options to pass to rust analyzer";
      };
    };
    python = mkEnableOption "Python LSP";
    clang = mkEnableOption "C language LSP";
    sql = mkEnableOption "SQL Language LSP";
    go = mkEnableOption "Go language LSP";
    ts = mkEnableOption "TS language LSP";
  };

  config = mkIf cfg.enable (
    let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in {
      vim.startPlugins = with pkgs.neovimPlugins;
        [
          nvim-lspconfig
          null-ls
          (
            if (config.vim.autocomplete.enable)
            then cmp-nvim-lsp
            else null
          )
          (
            if cfg.sql
            then sqls-nvim
            else null
          )
        ]
        ++ (
          if cfg.rust.enable
          then [
            plenary-nvim
            crates-nvim
            rust-tools
          ]
          else []
        );

      vim.configRC = ''
        ${
          if cfg.rust.enable
          then ''
            function! MapRustTools()
              nnoremap <silent><leader>ri <cmd>lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>
              nnoremap <silent><leader>rr <cmd>lua require('rust-tools.runnables').runnables()<CR>
              nnoremap <silent><leader>re <cmd>lua require('rust-tools.expand_macro').expand_macro()<CR>
              nnoremap <silent><leader>rc <cmd>lua require('rust-tools.open_cargo_toml').open_cargo_toml()<CR>
              nnoremap <silent><leader>rg <cmd>lua require('rust-tools.crate_graph').view_crate_graph('x11', nil)<CR>
            endfunction

            autocmd filetype rust nnoremap <silent><leader>ri <cmd>lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>
            autocmd filetype rust nnoremap <silent><leader>rr <cmd>lua require('rust-tools.runnables').runnables()<CR>
            autocmd filetype rust nnoremap <silent><leader>re <cmd>lua require('rust-tools.expand_macro').expand_macro()<CR>
            autocmd filetype rust nnoremap <silent><leader>rc <cmd>lua require('rust-tools.open_cargo_toml').open_cargo_toml()<CR>
            autocmd filetype rust nnoremap <silent><leader>rg <cmd>lua require('rust-tools.crate_graph').view_crate_graph('x11', nil)<CR>
          ''
          else ""
        }

        ${
          if cfg.nix
          then ''
            autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2
          ''
          else ""
        }

        ${
          if cfg.clang
          then ''
            " c syntax for header (otherwise breaks treesitter highlighting)
            " https://www.reddit.com/r/neovim/comments/orfpcd/question_does_the_c_parser_from_nvimtreesitter/
            let g:c_syntax_for_h = 1
          ''
          else ""
        }
      '';
      vim.luaConfigRC = ''
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        
        -- update when in insert
        vim.diagnostic.config({
            update_in_insert = true,
            underline = true,
            severity_sort = true,
            virtual_lines = false,
        })

        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = { noremap=true, silent=true }
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        local attach_keymaps = function(client, bufnr)
          local bufopts = { noremap=true, silent=true, buffer=bufnr }

          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, bufopts)

          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
          vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
        end

        local null_ls = require("null-ls")
        local null_helpers = require("null-ls.helpers")
        local null_methods = require("null-ls.methods")

        local ls_sources = {
          ${writeIf cfg.python
          ''
            null_ls.builtins.formatting.black.with({
              command = "${pkgs.black}/bin/black",
            }),
          ''}
          -- Commented out for now
          --${writeIf (config.vim.git.enable && config.vim.git.gitsigns.enable) ''
          --  null_ls.builtins.code_actions.gitsigns,
          --''}
          ${writeIf cfg.sql
          ''
            null_helpers.make_builtin({
              method = null_methods.internal.FORMATTING,
              filetypes = { "sql" },
              generator_opts = {
                to_stdin = true,
                ignore_stderr = true,
                suppress_errors = true,
                command = "${pkgs.sqlfluff}/bin/sqlfluff",
                args = {
                  "fix",
                  "-",
                },
              },
              factory = null_helpers.formatter_factory,
            }),

            null_ls.builtins.diagnostics.sqlfluff.with({
              command = "${pkgs.sqlfluff}/bin/sqlfluff",
              extra_args = {"--dialect", "postgres"}
            }),
          ''}
          ${writeIf cfg.nix
          ''
            null_ls.builtins.formatting.alejandra.with({
              command = "${pkgs.alejandra}/bin/alejandra"
            }),
          ''}

          ${writeIf cfg.ts
          ''
            null_ls.builtins.diagnostics.eslint,
            null_ls.builtins.formatting.prettier,
          ''}
        }

        vim.g.formatsave = ${
          if cfg.formatOnSave
          then "true"
          else "false"
        };

        -- Enable formatting
        format_callback = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              if vim.g.formatsave then
                  local params = require'vim.lsp.util'.make_formatting_params({})
                  client.request('textDocument/formatting', params, nil, bufnr)
              end
            end
          })
        end

        default_on_attach = function(client, bufnr)
          attach_keymaps(client, bufnr)
          format_callback(client, bufnr)
        end

        -- Enable null-ls
        require('null-ls').setup({
          diagnostics_format = "[#{m}] #{s} (#{c})",
          debounce = 250,
          default_timeout = 5000,
          sources = ls_sources,
          on_attach=default_on_attach
        })

        -- Enable lspconfig
        local lspconfig = require('lspconfig')

        local capabilities = vim.lsp.protocol.make_client_capabilities()

        ${let
          cfg = config.vim.autocomplete;
        in
          writeIf cfg.enable
          (
            ''
              capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
            ''
          )}

        ${writeIf cfg.rust.enable ''
          -- Rust config

          local rustopts = {
            tools = {
              autoSetHints = true,
              hover_with_actions = false,
              inlay_hints = {
                only_current_line = false,
              }
            },
            server = {
              capabilities = capabilities,
              on_attach = default_on_attach,
              cmd = {"${pkgs.rust-analyzer}/bin/rust-analyzer"},
              settings = {
                ${cfg.rust.rustAnalyzerOpts}
              }
            }
          }

          require('crates').setup {
            null_ls = {
              enabled = true,
              name = "crates.nvim",
            }
          }
          require('rust-tools').setup(rustopts)
        ''}

        ${writeIf cfg.python ''
          -- Python config
          lspconfig.pyright.setup{
            capabilities = capabilities;
            on_attach=default_on_attach;
            cmd = {"${pkgs.nodePackages.pyright}/bin/pyright-langserver", "--stdio"}
          }
        ''}

        ${writeIf cfg.nix ''
          -- Nix config
          lspconfig.rnix.setup{
            capabilities = capabilities;
            on_attach = function(client, bufnr)
              attach_keymaps(client, bufnr)
            end,
            cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"}
          }
        ''}

        ${writeIf cfg.clang ''
          -- CCLS (clang) config
          lspconfig.ccls.setup{
            capabilities = capabilities;
            on_attach=default_on_attach;
            cmd = {"${pkgs.ccls}/bin/ccls"}
          }
        ''}

        ${writeIf cfg.sql ''
          -- SQLS config
          lspconfig.sqls.setup {
            on_attach = function(client)
              client.server_capabilities.execute_command = true
              on_attach_keymaps(client, bufnr)
              require'sqls'.setup{}
            end,
            cmd = {"${pkgs.sqls}/bin/sqls", "-config", string.format("%s/config.yml", vim.fn.getcwd()) }
          }
        ''}

        ${writeIf cfg.go ''
          -- Go config
          lspconfig.gopls.setup {
            capabilities = capabilities;
            on_attach = default_on_attach;
            cmd = {"${pkgs.gopls}/bin/gopls", "serve"},
          }
        ''}

        ${writeIf cfg.ts ''
          -- TS config
          lspconfig.tsserver.setup {
            capabilities = capabilities;
            on_attach = function(client, bufnr)
              attach_keymaps(client, bufnr)
            end,
            cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
          }
        ''}
      '';
    }
  );
}

