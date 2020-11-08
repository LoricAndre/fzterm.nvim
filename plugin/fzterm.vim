" Commands
if !exists("g:fzterm_disable_com") || !g:fzterm_disable_com
  com Files lua require'fzterm'.files()
  com GFiles lua require'fzterm'.gitFiles()
  com Buffers lua require'fzterm'.buffers()
  com Branch lua require'fzterm'.branch()
  com Ag lua require'fzterm'.ag()
  com Rg lua require'fzterm'.rg()
  com FilesOrGFiles lua require'fzterm'.filesOrGitFiles()
  com Commits lua require'fzterm'.commits()
  com Blame lua require'fzterm'.blame()
  com Commit lua require'fzterm'.commit()
  com DocumentSymbols lua require'fzterm'.documentSymbols()
  com WorkspaceSymbols lua require'fzterm'.workspaceSymbols()
  com References lua require'fzterm'.references()
  com Mappings lua require'fzterm'.mappings()
endif
