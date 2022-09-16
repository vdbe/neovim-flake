{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.telescope;
in {
  options.vim.telescope = {
    enable = mkEnableOption "enable telescope";
  };


  config = mkIf cfg.enable (
    let
      writeIf = cond: msg: if cond
        then msg
        else "";
    in {
    vim.startPlugins = with pkgs.neovimPlugins; [
      telescope
    ];

    vim.luaConfigRC = ''
      require("telescope").setup {
        defaults = {
          vimgrep_arguments = {
            "${pkgs.ripgrep}/bin/rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          },
          pickers = {
            find_command = {
              "${pkgs.fd}/bin/fd",
            },
          },
        }
      }

      local git_opts = {
          use_git_root = true,
          show_untracked = true,
          --recurse_submodules = true,
      }

      local none_git_opts = {
          cwd = vim.g.root_dir,
      }

      project_files = function()
          local ok = pcall(require "telescope.builtin".git_files, git_opts)
          if not ok then require "telescope.builtin".find_files(none_git_opts)
          end
      end

      project_live_grep = function()
          require "telescope.builtin".live_grep(none_git_opts)
      end

      -- Search
      vim.api.nvim_set_keymap('n', '<leader><leader>', '<cmd>lua project_files()<cr>', { desc = 'Fuzzy search through the output of `git ls-files` command, respects .gitignore', noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>F', '<cmd>lua require("telescope.builtin").find_files()<cr>', { desc = 'Find files in the current working directory', noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<leader>sp', '<cmd>lua project_live_grep()<cr>', { desc = 'Live grep in the current working directory', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>bb', '<cmd>lua require("telescope.builtin").buffers()<cr>', { desc = 'Find open buffer', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>lua require("telescope.builtin").help_tags()<cr>', { desc = 'Search in the vim help files',  noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fc', '<cmd>lua require("telescope.builtin").commands()<cr>', { desc = 'Search for vim/plugin commands',  noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>fp', '<cmd>lua require("telescope.builtin").pickers()<cr>', { desc = 'Lists the previous pickers incl. multi-selections',  noremap = true, silent = true })

      -- Git
      vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>lua require("telescope.builtin").git_branches()<cr>', { desc = 'Change git branch', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>gt', '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<cr>', { desc = 'Change git working tree', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>gT', '<cmd>lua require("telescope").extensions.git_worktree.create_git_worktree()<cr>', { desc = 'delete git working tree', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>gc', '<cmd>lua require("telescope.builtin").git_commits()<cr>', { desc = 'Lists git commits with diff preview, checkout action <cr>, reset mixed <C-r>m, reset soft <C-r>s and reset hard <C-r>h', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>gC', '<cmd>lua require("telescope.builtin").git_bcommits()<cr>', { desc = 'Lists buffer\'s git commits with diff preview and checks them out on <cr>', noremap = true, silent = true })

      ${writeIf config.vim.lsp.enable ''
      -- Lsp
      vim.api.nvim_set_keymap('n', "<leader>flsb", "<cmd> Telescope lsp_document_symbols<CR>", { desc = 'Lists LSP document symbols in the current buffer', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>flsw", "<cmd> Telescope lsp_workspace_symbols<CR>", { desc = 'Lists LSP document symbols in the current workspace', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>flr", "<cmd> Telescope lsp_references<CR>", { desc = 'Lists LSP references for word under the cursor', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>fli", "<cmd> Telescope lsp_implementations<CR>", { desc = 'Goto the implementation of the word under the cursor if there\'s only one, otherwise show all options in Telescope', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>flD", "<cmd> Telescope lsp_definitions<CR>", { desc = 'Goto the definition of the word under the cursor, if there\'s only one, otherwise show all options in Telescope', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>flt", "<cmd> Telescope lsp_type_definitions<CR>", { desc = 'Goto the definition of the type of the word under the cursor, if there\'s only one, otherwise show all options in Telescope', noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', "<leader>fld", "<cmd> Telescope diagnostics<CR>", { desc = 'Lists Diagnostics for all open buffers', noremap = true, silent = true })
      ''}

      ${writeIf config.vim.treesitter.enable ''
      -- Treesitter
      vim.api.nvim_set_keymap('n', '<leader>fs', '<cmd>lua require("telescope.builtin").treesitter()<cr>', { desc = 'Lists Function names, variables, from Treesitter', noremap = true, silent = true })
      ''}
    '';

  }
  );
}
