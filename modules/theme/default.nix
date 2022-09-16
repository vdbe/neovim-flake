{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./gruvbox.nix
    ./config.nix
  ];
}
