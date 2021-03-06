local vim = vim -- just so lsp will shut up

return {

  fzterm = require'fzterm.main',

  gitFiles = function()
    return require'fzterm.main'("git ls-files")
  end,

  files = function()
    local formatIgnore = function()
      local res = ""
      for _, path in pairs(vim.g.fzterm_ignore) do
        res = res .. path .. "\\n"
      end
      return res
    end
    if vim.g.fzterm_ignore then
      local ignoreFile = formatIgnore()
      return require'fzterm.main'("rg --files --hidden . --ignore-file <(echo '" .. ignoreFile .. "')")
    else
      return require'fzterm.main'("rg --files --hidden .")
    end
  end,

  buffers = function()
    local matcher = "fzf -m --preview 'bat --color=always -n \"$(echo {2} | sed \"'\"s;~;$HO  ;\"\'\")\"' -d '\"'"
    return require'fzterm.main'(":ls", "awk '{print $1}'", matcher, true, "buffer")
  end,

  branch = function()
    local matcher = "fzf"
    return require'fzterm.main'("git branch", "xargs git checkout -q > /dev/null 2>&1", matcher, false, "edit!")
  end,

  ag = function()
    local matcher = "fzf -m --preview 'ag --color -n -C 8 -Q {-1} {1}' -d ':'"
    local cmd = "ag --nobreak --noheading '.+' ."
    local formatIgnore = function()
      for _, path in pairs(vim.g.fzterm_ignore) do
        cmd = cmd .. " --ignore \"" .. path .. "\""
      end
    end
    if vim.g.fzterm_ignore then
      formatIgnore()
      print(cmd)
    end
    return require'fzterm.main'(cmd, "awk -F: '{printf \"+\\%s \\%s\", $2, $1}'", matcher)
  end,

  rg = function()
    local cmd = "rg --hidden ."
    local formatIgnore = function()
      local res = ""
      for _, path in pairs(vim.g.fzterm_ignore) do
        res = res .. path .. "\\n"
      end
      return res
    end
    if vim.g.fzterm_ignore then
      local ignoreFile = formatIgnore()
      cmd = "rg --hidden . --ignore-file <(echo '" .. ignoreFile .. "')"
    end
    local matcher = "fzf -m --preview 'rg -C 10 --color=always -F {-1} {1}' -d ':'"
    return require'fzterm.main'(cmd, "cut -d':' -f1", matcher)
  end,

  filesOrGitFiles = function()
    if vim.fn.isdirectory('.git') == 1 then
      return require'fzterm'.gitFiles()
    else
      return require'fzterm'.files()
    end
  end,

  commits = function()
    local pre_cmd = "git log --pretty=oneline"
    local matcher = "fzf -n2.. --preview=\"awk '{print $1}' | xargs git show --pretty='\\%Cred\\%H\\%n\\%Cblue\\%an\\%n\\%Cgreen\\%s'"
    .. " -1 --name-only --color {1}\""
    return require'fzterm.main'(pre_cmd, "false", matcher)
  end,

  blame = function()
    local pre_cmd = "git blame -s " .. vim.fn.expand('%')
    local matcher = "fzf --preview \"git show --pretty='\\%Cred\\%H\\%n\\%Cblue\\%an\\%n\\%Cgreen\\%s'"
    .. " -1 --name-only --color -n1 {1}\" -n2.."
    return require'fzterm.main'(pre_cmd, "false", matcher)
  end,

  commit = function()
    return require'fzterm.main'('git commit -a || true', false, 'xargs echo && echo "\\n\\nPress enter to continue..." && read')
  end,

  workspaceSymbols = function()
    local cmd = ":call luaeval(\"require'fzterm.utils'.lsp('workspace/symbol', 'symbols')\")"
    local matcher = "fzf --preview='bat --highlight-line {-1} -r{-1}: {-2} --color=always' --with-nth=..-3"
    return require'fzterm.main'(cmd, "awk '{printf \"+\\%s \\%s\", $NF, $(NF-1)}'", matcher, true)
  end,

  documentSymbols = function()
    local cmd = ":call luaeval(\"require'fzterm.utils'.lsp('textDocument/documentSymbol', 'symbols')\")"
    local matcher = "fzf --preview='bat --highlight-line {-1} -r{-1}: {-2} --color=always' --with-nth=..-3"
    return require'fzterm.main'(cmd, "awk '{printf \"+\\%s \\%s\", $NF, $(NF-1)}'", matcher, true)
  end,

  references = function()
    local cmd = ":call luaeval(\"require'fzterm.utils'.lsp('textDocument/references', 'locations')\")"
    local matcher = "fzf --preview='bat --highlight-line {-1} -r{-1}: {-2} --color=always' --with-nth=..-3"
    return require'fzterm.main'(cmd, "awk '{printf \"+\\%s \\%s\", $NF, $(NF-1)}'", matcher, true)
  end,

  mappings = function()
    return require'fzterm.main'(":0verbose map", "false", "fzf", true)
  end,

  colors = function()
    return require'fzterm.main'(":echo join(getcompletion('', 'color'), '\n')", false, "fzf", true, ":colorscheme")
  end,

  ranger = function()
    return require'fzterm'.fzterm('false', false, 'r() {ranger --choosefiles=/tmp/fzterm} && r', false, false, true)
  end
}
