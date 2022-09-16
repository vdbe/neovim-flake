{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.lsp = {
      enable = mkDefault false;

      formatOnSave = mkDefault false;

      lspSignature = {
        enable = mkDefault true;
      };

      lspsaga = {
        enable = mkDefault false;
      };

      nvimCodeActionMenu = {
        enable = mkDefault true;
      };

      nix = mkDefault false;

      rust = {
        enable = mkDefault false;
      };

      python = mkDefault false;
      clang = mkDefault false;
      sql = mkDefault false;
      go = mkDefault false;
      ts = mkDefault false;

    };
  };
}
