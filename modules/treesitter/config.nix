{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.treesitter = {
      enable = mkDefault false;

      fold = mkDefault false;

      highlight = {
        enable = mkDefault true;

	disable = mkDefault [];

	additional_vim_regex_highlighting = mkDefault false;
      };

      indent = {
        enable = mkDefault true;
      };

      autotagHtml = mkDefault false;

      grammars = mkDefault [];

      context = {
        enable = mkDefault false;
      };
    };
  };
}
