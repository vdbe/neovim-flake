{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./keybinds.nix
    ./config.nix
  ];
}
