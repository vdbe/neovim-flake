{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
in {
  options.vim = {
    autocomplete = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable autocomplete";
      };

      type = mkOption {
        default = "nvim-cmp";
        description = "Set the autocomplete plugin. Options: [nvim-cmp] nvim-compe";
        type = types.enum ["nvim-compe" "nvim-cmp"];
      };
    };
  };

  config = mkIf (cfg.enable) (
    let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in {
      vim.startPlugins = with pkgs.neovimPlugins;
        (
          [
            nvim-cmp
            cmp-buffer
            cmp_luasnip
            cmp-path
            cmp-treesitter
          ]
        );

      vim.snippets.luasnip.enable = true;
      vim.luaConfigRC = ''
        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end
        local feedkey = function(key, mode)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
        end
        local cmp = require'cmp'
        local luasnip = require("luasnip")
        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          sources = {
            ${writeIf (config.vim.lsp.enable) "{ name = 'nvim_lsp' },"}
            ${writeIf (config.vim.lsp.rust.enable) "{ name = 'crates' },"}
            { name = 'luasnip' },
            { name = 'treesitter' },
            { name = 'path' },
            { name = 'buffer' },
          },
          mapping = {
            ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c'}),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c'}),
            ['<C-y>'] = cmp.config.disable,
            ['<C-e>'] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
            ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
            ['<CR>'] = cmp.mapping.confirm({
              select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          },
          completion = {
            completeopt = 'menu,menuone,noinsert',
          },
          formatting = {
            format = function(entry, vim_item)
              -- type of kind
              vim_item.kind = ${
          writeIf (config.vim.visuals.lspkind.enable)
          "require('lspkind').presets.default[vim_item.kind] .. ' ' .."
        } vim_item.kind
              -- name for each source
              vim_item.menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                vsnip = "[VSnip]",
                crates = "[Crates]",
                path = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }
        })
        ${writeIf (config.vim.autopairs.enable && config.vim.autopairs.type == "nvim-autopairs") ''
          local cmp_autopairs = require('nvim-autopairs.completion.cmp')
          cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { text = ""} }))
        ''}
      '';

    }
  );
}
