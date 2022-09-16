{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.snippets.luasnip;
in {
  options.vim.snippets.luasnip = {
    enable = mkEnableOption "Enable luasnip";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [luasnip];
  };
}
