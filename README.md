# FZTerm

## Idea
FZTerm is my attempt at a fuzzy finder plugin, using a floating terminal and basically nothing else.
The basic idea is to make it fully customizable, the plugins provides the basic framework and a few implementations.
The only dependencies are bat, fzf and ag, but the framework is still usable without them. 

## Usage
![](usage.gif)
 - Implemented commands :
   - `:Files` lists files in your directory, respecting `g:fzterm_ignore` but showing other hidden files (calls `lua require'fzterm'.files()`)
   - `:GFiles` lists the files tracked by git (calls `lua require'fzterm'.gitFiles()`)
   - `:Buffers` lists open buffers (calls `lua require'fzterm'.buffers()`)
   - `:Branches` lists branches and lets you checkout to the one you select (calls `lua require'fzterm'.branch()`)
   - `:Ag` searches inside files with the Silver Searcher, `g:fzterm_ignore` is respected (calls `lua require'fzterm'.ag()`)
   - `:Rg` searches inside files with ripgrep, `g:fzterm_ignore` is respected (calls `lua require'fzterm'.rg()`)
   - `:FilesOrGFiles` runs `:Files` or `:GFiles` depending on if vim's working dir is a git repo (calls `lua require'fzterm'.filesOrGitFiles()`)
   - `:Commits` lists previous commits and calls `git show` on the selected commit's hash (calls `lua require'fzterm'.commits()`)
   - `:Blame` shows git blame for the current buffer, with commit info in the preview window. Matching is done on any field but the commit hash (calls `lua require'fzterm'.blame()`)
 - You can use the basic commands by simply calling them or mapping them, for example `nnoremap <leader>f :Files<CR>`. 

## Configuration
 - The `g:fzterm_ignore` can be used to ignore files, for example `let g:fzterm_ignore = {'.git', 'node_modules'}`
 - The window's geometry can be configured using the following global variables:
   - `g:fzterm_width` sets the absolute width in columns
   - `g:fzterm_height` sets the absolute height in lines
   - `g:fzterm_width_ratio` is the ratio between the floating window width and the editor window's (default is "0.75")
   - `g:fzterm_height_ratio` is the ratio between the floating window height and the editor window's (default is "0.75")
   - `g:fzterm_margin_left` is the ratio of the editor window left as a margin on the left side of the floating window (default is "0.25")
   - `g:fzterm_margin_top` is the ratio of the editor window top as a margin on the top side of the floating window (default is "0.25")
   - For example, here is the config for a window that would span the whole width, half the height and would be docked at the bottom :
   ```
   let g:fzterm_width_ratio = "1"
   let g:fzterm_height_ration = "0.5"
   let g:fzterm_margin_left = "0"
   let g:fzterm_margin_top = "0.5"
   ```
 - The `g:fzterm_disable_com` variable can be set to true to disable all built-in commands. If you set this, you will need to manually configure your commands : 
  `command Files lua require'fzterm'.files()`


## Extensions
 - The plugins provides the `fzterm` function, accessible via `lua require'fzterm'.fzterm()`
 - The function takes 5 arguments, the first 3 are shell commands :
   - `pre_cmd`, the command that will be piped into fzf or any fuzzy finder you choose (see 'matcher' arg)
   - `post_cmd`, the command the result is piped into, if empty or `false` the result is simply opened in a new buffer
   - `matcher`, what pre_cmd is piped into, usually fzf with args (default is `fzf --preview -m 'bat --color=always -n {}'`)
   - `internal` changes the way `pre_cmd` is ran : if `true`, pre_cmd can be a vim command and will be executed in the current buffer
   - `edit_cmd` is the command ran by neovim to open the result(s) (default is "edit")
 - For example, here would be the code to change `rg` to a basic `find` for the `:Files` command :
   - lua :
   ```lua
    local fzterm = require'fzterm'
    fzterm.files = function()
      local pre_cmd = "find ."
      fzterm.fzterm(pre_cmd)
    end
   ```
   - For vimscript, you would wrap the code block into :
   ```
   lua << EOF
     CODE_HERE 
   EOF
   ```
 - To use them in an init.vim, you can add something like this : 
 ```
   command FilesExcludeHidden :lua require'fzterm'.fzterm('rg --files .')
 ```

