local vim = vim -- just so lsp will shut up
local api = vim.api

M = {}

function M.fzterm(pre_cmd, post_cmd, matcher, internal)
  local buf = api.nvim_create_buf(false, false)

  -- Window geometry
  local editor_width = api.nvim_get_option('columns')
  local editor_height = api.nvim_get_option('lines')
  local win_width = math.floor(vim.g.fzterm_width or editor_width * 3 / 4)
  local win_height = math.floor(vim.g.fzterm_height or editor_height / 2)
  local margin_top = math.floor((editor_height - win_height) / 2)
  local margin_left = math.floor((editor_width - win_width) / 2)
  -- Bindings
  local default_matcher = "fzf -m --preview 'bat --color=always {}'"
  matcher = matcher or default_matcher
  -- Open the window
  local opt = {
    relative = 'editor',
    row = margin_top,
    col = margin_left,
    width = win_width,
    height = win_height,
  }
  api.nvim_open_win(buf, true, opt)

  -- Maybe we'll use fd at some point, but for middle-scale projects it's an unnecessary dependency
  if internal then
    api.nvim_command(":redir! > /tmp/fztermcmd | silent " .. pre_cmd .. " | redir end")
    pre_cmd = "sed 1d /tmp/fztermcmd"
  end
  if post_cmd then
    post_cmd = " | " .. post_cmd
  else
    post_cmd = ""
  end

  api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<C-\\><C-n>:q<CR>', {})
  api.nvim_command(":term " .. pre_cmd .. " | ".. matcher .. post_cmd .. " > /tmp/fzterm")
  api.nvim_command(":start")
  local on_close = ":au BufEnter * ++once let f = readfile('/tmp/fzterm') | "
  on_close = on_close .. "if !empty(f) | "
  on_close = on_close .. "for l in f | execute 'edit' f[0] | endfor"
  on_close = on_close .. " | endif"
  api.nvim_command(on_close)
end

M.gitFiles = function()
  M.fzterm("git ls-files")
end

M.files = function()
  M.fzterm("rg --files --hidden .")
end

M.buffers = function()
  local matcher = "fzf -m --preview 'bat --color=always {2}' -d '\"'"
  M.fzterm(":ls", "cut -d'\"' -f2", matcher, true)
end

M.branch = function()
  local matcher = "fzf"
  M.fzterm("git branch", "xargs git checkout > /dev/null 2>&1", matcher)
end

M.ag = function()
  local matcher = "fzf -m --preview 'ag --color --nonumber -C 8 {-1} {1}' -d ':'"
  M.fzterm("ag --nobreak --noheading '.+' .", "awk -F: '{printf \"+\\%s \\%s\", $2, $1}'", matcher)
end

return M
