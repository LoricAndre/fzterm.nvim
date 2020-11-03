" Commands
if !exists("g:fzterm_disable_com") || !g:fzterm_disable_com
  com Files lua require'fzterm'.files()
  com GFiles lua require'fzterm'.gitFiles()
  com Buffers lua require'fzterm'.buffers()
  com Branch lua require'fzterm'.branch()
  com Ag lua require'fzterm'.ag()
  com Rg lua require'fzterm'.rg()
  com FilesOrGFiles lua require'fzterm'.filesOrGitFiles()
endif
