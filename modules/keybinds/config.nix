{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.keybinds = {
      enable = mkDefault true;
    };
  };
}
