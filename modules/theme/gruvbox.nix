{
  pkgs,
  config,
  lib,
  ...
}:
  with lib;
  with builtins;
let
  cfg = config.vim.theme.gruvbox;
in {
  options.vim.theme.gruvbox = {
    enable = mkEnableOption "Enable gruvbox";

    undercurl = mkOption {
      type = types.bool;
      description = "Enable undercurl for gruvbox";
    };

    underline = mkOption {
      type = types.bool;
      description = "Enable underline for gruvbox";
    };

    bold = mkOption {
      type = types.bool;
      description = "Enable bold for gruvbox";
    };

    italic = mkOption {
      type = types.bool;
      description = "Enable italic for gruvbox";
    };

    strikethrough = mkOption {
      type = types.bool;
      description = "Enable strikethrough for gruvbox";
    };

    invert_selection = mkOption {
      type = types.bool;
      description = "Enable invert_selection for gruvbox";
    };

    invert_signs = mkOption {
      type = types.bool;
      description = "Enable invert_signs for gruvbox";
    };

    invert_tabline = mkOption {
      type = types.bool;
      description = "Enable invert_tabline for gruvbox";
    };

    invert_intend_guides = mkOption {
      type = types.bool;
      description = "Enable invert_intend_guides for gruvbox";
    };

    inverse = mkOption {
      type = types.bool;
      description = "Invert background for search, diffs, statuslines and errors";
    };

    contrast = mkOption {
      description = "can be hard, soft or empty string";
      type = types.enum (
        [
          ""
	  "soft"
	  "hard"
        ]
      );
    };
  };

  config = mkIf (cfg.enable) (
  let 
   bool2str = condition: if condition then "true" else "false";
  in {
    vim.startPlugins = with pkgs.neovimPlugins; [ gruvbox ];
    vim.luaConfigRC = ''
      local gruvbox = require('gruvbox')
      gruvbox.setup({
        undercurl = ${bool2str cfg.undercurl},
        underline = ${bool2str cfg.underline},
        bold = ${bool2str cfg.bold},
        italic = ${bool2str cfg.italic},
        strikethrough = ${bool2str cfg.strikethrough},
        invert_selection = ${bool2str cfg.invert_selection},
        invert_signs = ${bool2str cfg.invert_signs},
        invert_tabline = ${bool2str cfg.invert_tabline},
        invert_intend_guides = ${bool2str cfg.invert_intend_guides},
        inverse = ${bool2str cfg.inverse},
	${
        if cfg.contrast != ""
	then "contrast = ${cfg.contrast},"
	else ""
	}
        overrides = {},
      })
      vim.cmd("colorscheme gruvbox")
    '';
  });
}
