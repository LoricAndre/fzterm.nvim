local vim = vim

return function(pre_cmd, post_cmd, matcher, internal, edit_cmd)
  local base_win = vim.api.nvim_get_current_win()
  local tmp = require'fzterm.utils'.get_tmp()

  -- Window geometry
  local editor_width = vim.api.nvim_get_option('columns')
  local editor_height = vim.api.nvim_get_option('lines')
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
  if internal then
    vim.cmd(":redir! > " .. tmp .. "/fztermcmd | silent! " .. pre_cmd .. " | redir end")
    pre_cmd = "sed 1d ".. tmp .. "/fztermcmd"
  end
  if post_cmd then
    post_cmd = " | " .. post_cmd
  else
    post_cmd = ""
  end
  local cmd = edit_cmd or "edit"
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_open_win(buf, true, opt)
  vim.cmd(":term " .. pre_cmd .. " | ".. matcher .. post_cmd .. " > " .. tmp .. "/fzterm")
  vim.cmd(":start")
  vim.cmd(":au TermClose <buffer> :lua require'fzterm.utils'.exec_and_close("
  .. base_win ..  ", "
  .. buf .. ", \""
  .. cmd .. "\")")
end
