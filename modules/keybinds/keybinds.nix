{ pkgs, lib, config, ...}:
with lib;
with builtins;

let
  cfg = config.vim.keybinds;
in {
  options.vim.keybinds = {
    enable = mkEnableOption "enable custom basic keybinds";
  };

  config = mkIf cfg.enable
  {
    vim.luaConfigRC = ''
    -- Exit to normal mode with jk
    vim.keymap.set({'!'}, 'jk', [[<c-\><c-n>]], { desc = "exit to normal mode" })
    vim.keymap.set({'t'}, 'jk', [[<c-\><c-n>]], { desc = "exit to normal mode" })

    -- Move lines in visual mode with J/K
    vim.keymap.set({'v'}, "J", ":m '>+1<CR>gv=gv", { desc = "move line down" } )
    vim.keymap.set({'v'}, "K", ":m '<-2<CR>gv=gv", { desc = "move line up" } )

    -- Copy to system clipboard
    vim.keymap.set({'v', 'n'}, "<leader>y", "\"+y", { desc = "copy to clipboard" } )
    vim.keymap.set({'n'}, "<leader>Y", "\"+Y", { desc = "copy line to clipboard" } )

    --
    -- Window navigation
    vim.keymap.set({'n'}, '<leader>ww', '<cmd>wincmd w<CR>')
    vim.keymap.set({'n'}, '<leader>wh', '<cmd>wincmd h<CR>')
    vim.keymap.set({'n'}, '<leader>wj', '<cmd>wincmd j<CR>')
    vim.keymap.set({'n'}, '<leader>wk', '<cmd>wincmd k<CR>')
    vim.keymap.set({'n'}, '<leader>wl', '<cmd>wincmd l<CR>')
    
    -- Window movement
    vim.keymap.set({'n'}, '<leader>wr', '<cmd>wincmd r<CR>')
    vim.keymap.set({'n'}, '<leader>wR', '<cmd>wincmd R<CR>')
    vim.keymap.set({'n'}, '<leader>wx', '<cmd>wincmd x<CR>')
    vim.keymap.set({'n'}, '<leader>wH', '<cmd>wincmd H<CR>')
    vim.keymap.set({'n'}, '<leader>wJ', '<cmd>wincmd J<CR>')
    vim.keymap.set({'n'}, '<leader>wK', '<cmd>wincmd K<CR>')
    vim.keymap.set({'n'}, '<leader>wL', '<cmd>wincmd L<CR>')
    
    -- Window spliting
    vim.keymap.set({'n'}, '<leader>wv', '<cmd>vsplit<CR>')
    vim.keymap.set({'n'}, '<leader>ws', '<cmd>split<CR>')
    
    -- Buffer navigation
    vim.keymap.set({'n'}, '<leader>bl', '<cmd>e#<CR>')
    vim.keymap.set({'n'}, '<leader>bp', '<cmd>bprevious<CR>')
    vim.keymap.set({'n'}, '<leader>bn', '<cmd>bnext<CR>')
    vim.keymap.set({'n'}, '<leader>bd', '<cmd>bdelete<CR>')
    '';
  };
}

