{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
in {
  options.vim.treesitter = {
    enable = mkOption {
      description = "enable tree-sitter [nvim-treesitter]";
      type = types.bool;
    };

    fold = mkOption {
      description = "enable fold with tree-sitter";
      type = types.bool;
    };

    highlight = {
      enable = mkEnableOption "enable treesitter highlighting";

      disable = mkOption {
        description = "Disable treesitter highlight for the file types";
        type = with types; listOf (types.str);
      };

      additional_vim_regex_highlighting = mkEnableOption "Additional vim regex highlighting";
    };

    indent = {
      enable = mkEnableOption "enable treesitter highlighting";
    };

    autotagHtml = mkOption {
      description = "enable autoclose and rename html tag [nvim-ts-autotag]";
      type = types.bool;
    };

    grammars = mkOption {
      description = "List of treesitter grammars";
      type = with types; listOf (nullOr package);
    };
  };

  config = mkIf cfg.enable (
    let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
      bool2str = condition: if condition then "true" else "false";

    in {
      vim.startPlugins = with pkgs.neovimPlugins; [
	(
          if length cfg.grammars > 0
          then null
          else nvim-treesitter
	)
	(
          if cfg.autotagHtml
          then nvim-ts-autotag
          else null
        )
      ];

      vim.configRC = writeIf cfg.fold ''
        " Tree-sitter based folding
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable
      '';


      #TODO: disable = ${if length cfg.highlight.disable > 0 then concatStringsSep ", " cfg.highlight.disable else ""},
      vim.luaConfigRC = ''
        -- Treesitter config
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = ${bool2str cfg.highlight.enable},
	    disable = "",
            additional_vim_regex_highlighting = ${bool2str cfg.highlight.additional_vim_regex_highlighting},
          },

          indent = {
            enable = ${bool2str cfg.indent.enable}
          },

          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },

	 ${writeIf cfg.autotagHtml ''
         autotag = {
           enable = true,
         },
        ''}
        }
      '';
    }
  );
}
