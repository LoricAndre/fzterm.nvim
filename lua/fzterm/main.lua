local vim = vim

return function(pre_cmd, post_cmd, matcher, internal, edit_cmd, no_redir)
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
    local lnumber = function(filename)
      local res = 0
      for _ in io.lines(filename) do
        res = res + 1
      end
      return res
    end
    if lnumber(tmp .. "/fztermcmd") == 0 then
      return
    end
  end
  if post_cmd then
    post_cmd = " | " .. post_cmd
  else
    post_cmd = ""
  end
  edit_cmd = edit_cmd or "edit"
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_open_win(buf, true, opt)
  local cmd = ":term " .. pre_cmd .. " | ".. matcher .. post_cmd
  if not no_redir then
    cmd = cmd .. " > " .. tmp .. "/fzterm"
  end
  vim.cmd(cmd)
  vim.cmd(":start")
  vim.cmd(":au TermClose <buffer> :lua require'fzterm.utils'.exec_and_close("
  .. base_win ..  ", "
  .. buf .. ", \""
  .. edit_cmd .. "\")")
end
