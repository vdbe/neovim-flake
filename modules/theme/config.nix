{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.theme.gruvbox = {
      enable = mkDefault false;

      undercurl = mkDefault true;

      underline = mkDefault true;

      bold = mkDefault true;

      italic = mkDefault true;

      strikethrough = mkDefault true;

      invert_selection = mkDefault false;

      invert_signs = mkDefault false;

      invert_tabline = mkDefault false;

      invert_intend_guides = mkDefault false;

      inverse = mkDefault true;

      contrast = mkDefault "";
    };
  };
}
