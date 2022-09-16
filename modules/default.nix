{config, lib, pkgs, ...}:
{
  imports = [
    ./core
    ./autopairs
    ./basic
    ./keybinds
    ./theme
    ./completion
    ./telescope
    ./statusline
    ./snippets
    ./treesitter
    ./lsp
    #./fuzzyfind
    #./filetree
    ./git
    ./visuals
    #./formating
    #./editor
    #./test
  ];
}
