local vim = vim -- just so lsp will shut up
local api = vim.api

M = {}

local function get_tmp()
  local tmp = "/tmp"
  if vim.fn.has("win32") == 1 then
    tmp = vim.env.TEMP or "/temp"
  end
  return tmp
end

function M.fzterm(pre_cmd, post_cmd, matcher, internal, edit_cmd)
  local base_win = api.nvim_get_current_win()
  local buf = api.nvim_create_buf(false, false)
  local tmp = get_tmp()

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
  if internal then
    api.nvim_command(":redir! > " .. tmp .. "/fztermcmd | silent " .. pre_cmd .. " | redir end")
    pre_cmd = "sed 1d ".. tmp .. "/fztermcmd"
  end
  if post_cmd then
    post_cmd = " | " .. post_cmd
  else
    post_cmd = ""
  end
  local cmd = edit_cmd or "edit"
  api.nvim_command(":term " .. pre_cmd .. " | ".. matcher .. post_cmd .. " > " .. tmp .. "/fzterm")
  api.nvim_command(":start")
  api.nvim_command(":au TermClose <buffer> :lua require'fzterm'.exec_and_close("
  .. base_win ..  ", "
  .. buf .. ", \""
  .. cmd .. "\")")
end

local edit = function(cmd)
  local tmp = get_tmp()
  local f = io.open(tmp .. "/fzterm")
  for l in f:lines() do
    vim.cmd(":" .. cmd .. " " .. l)
  end
end

M.exec_and_close = function(base_win, buf, edit_cmd)
  local float_win = api.nvim_get_current_win()
  api.nvim_set_current_win(base_win)
  print("b", edit_cmd)
  vim.defer_fn(function() return edit(edit_cmd) end, 10)
  api.nvim_win_close(float_win, true)
  api.nvim_buf_delete(buf, {force = true})
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
    M.fzterm("rg --files --hidden . --ignore-file <(echo '" .. ignoreFile .. "')")
  else
    M.fzterm("rg --files --hidden .")
  end
end

M.buffers = function()
  local matcher = "fzf -m --preview 'bat --color=always -n \"$(echo {2} | sed \"'\"s;~;$HOME;\"\'\")\"' -d '\"'"
  M.fzterm(":ls", "awk '{print $1}'", matcher, true, "buffer")
end

M.branch = function()
  local matcher = "fzf"
  M.fzterm("git branch", "xargs git checkout > /dev/null 2>&1", matcher)
end

M.ag = function()
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
  M.fzterm(cmd, "awk -F: '{printf \"+\\%s \\%s\", $2, $1}'", matcher)
end

M.rg = function()
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
  M.fzterm(cmd, "cut -d':' -f1", matcher)
end

M.filesOrGitFiles = function()
  if vim.fn.isdirectory('.git') then
    M.gitFiles()
  else
    M.files()
  end
end

M.commits = function()
  local pre_cmd = "git log --pretty=oneline"
  local matcher = "fzf -n2.. --preview=\"awk '{print $1}' | xargs git show --pretty='\\%Cred\\%H\\%n\\%Cblue\\%an\\%n\\%Cgreen\\%s'"
      .. " -1 --name-only --color {1}\""
  M.fzterm(pre_cmd, "false", matcher)
end

M.blame = function()
  local pre_cmd = "git blame -s " .. vim.fn.expand('%')
  local matcher = "fzf --preview \"git show --pretty='\\%Cred\\%H\\%n\\%Cblue\\%an\\%n\\%Cgreen\\%s'"
      .. " -1 --name-only --color -n1 {1}\" -n2.."
  M.fzterm(pre_cmd, "false", matcher)
end

M.commit = function()
  M.fzterm('git commit -a -q || true', false, 'xargs echo && echo "\\n\\nPress enter to continue..." && read')
end

return M
