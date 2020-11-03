local vim = vim -- just so lsp will shut up
local api = vim.api

M = {}

function M.fzterm(pre_cmd, post_cmd, matcher, internal)
  local buf = api.nvim_create_buf(false, false)

  -- Window geometry
  local editor_width = api.nvim_get_option('columns')
  local editor_height = api.nvim_get_option('lines')
  local win_width = math.floor(vim.g.fzterm_width or editor_width * (vim.g.fzterm_width_ratio or 0.75))
  local win_height = math.floor(vim.g.fzterm_height or editor_height * (vim.g.fzterm_height_ratio or 0.5))
  local margin_top = math.floor((editor_height - win_height) * (vim.g.fzterm_margin_top or 0.25) * 2)
  local margin_left = math.floor((editor_width - win_width) * (vim.g.fzterm_margin_left or 0.25) * 2)
  -- Bindings
  local default_matcher = "fzf -m --preview 'bat --color=always -n {}'"
  matcher = matcher or default_matcher
  -- Open the window
  local opt = {
    relative = 'editor',
    row = margin_top,
    col = margin_left,
    width = win_width,
    height = win_height,
    style = 'minimal'
  }
  api.nvim_open_win(buf, true, opt)
  local tmp = "/tmp"
  if vim.has("win32") then
    tmp = vim.env("TEMP")
  end
  if internal then
    api.nvim_command(":redir! > " .. tmp .. "/fztermcmd | silent " .. pre_cmd .. " | redir end")
    pre_cmd = "sed 1d ".. tmp .. "/fztermcmd"
  end
  if post_cmd then
    post_cmd = " | " .. post_cmd
  else
    post_cmd = ""
  end

  api.nvim_command(":term " .. pre_cmd .. " | ".. matcher .. post_cmd .. " > " .. tmp .. "/fzterm")
  api.nvim_command(":start")
  api.nvim_command(':set ft=fzterm')
  local on_close = ":au BufEnter * ++once let f = readfile('" .. tmp.. "/fzterm') | "
  on_close = on_close .. "if !empty(f) | "
  on_close = on_close .. "for l in f | execute 'edit' f[0] | endfor"
  on_close = on_close .. " | endif"
  api.nvim_command(on_close)
end

M.gitFiles = function()
  M.fzterm("git ls-files")
end

M.files = function()
  local formatIgnore = function()
    local res = ""
    for _, path in pairs(vim.g.fzterm_ignore) do
      res = res .. path .. "\\n"
    end
    return res
  end
  if vim.g.fzterm_ignore then
    local ignoreFile = formatIgnore()
    print(ignoreFile)
    M.fzterm("rg --files --hidden . --ignore-file <(echo '" .. ignoreFile .. "')")
  else
    M.fzterm("rg --files --hidden .")
  end
end

M.buffers = function()
  local matcher = "fzf -m --preview 'bat --color=always -n {2}' -d '\"'"
  M.fzterm(":ls", "cut -d'\"' -f2", matcher, true)
end

M.branch = function()
  local matcher = "fzf"
  M.fzterm("git branch", "xargs git checkout > /dev/null 2>&1", matcher)
end

M.ag = function()
  local matcher = "fzf -m --preview 'ag --color -n -C 8 {-1} {1}' -d ':'"
  local cmd = "ag --nobreak --noheading '.+' ."
  local formatIgnore = function()
    for _, path in pairs(vim.g.fzterm_ignore) do
      cmd = cmd .. " --ignore ".. path
    end
  end
  if vim.g.fzterm_ignore then
    formatIgnore() 
  end
  M.fzterm(cmd, "awk -F: '{printf \"+\\%s \\%s\", $2, $1}'", matcher)
end

M.filesOrGitFiles = function()
  if vim.fn.isdirectory('.git') then
    M.gitFiles()
  else
    M.files()
  end
end

return M
