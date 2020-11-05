local vim = vim
M = {}
M.get_tmp = function()
  local tmp = "/tmp"
  if vim.fn.has("win32") == 1 then
    tmp = vim.env.TEMP or "/temp"
  end
  return tmp
end

local edit = function(cmd)
  local tmp = M.get_tmp()
  local f = io.open(tmp .. "/fzterm")
  for l in f:lines() do
    vim.cmd(":" .. cmd .. " " .. l)
  end
end

M.exec_and_close = function(base_win, buf, edit_cmd)
  local float_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(base_win)
  vim.defer_fn(function() return edit(edit_cmd) end, 10)
  vim.api.nvim_win_close(float_win, true)
  vim.api.nvim_buf_delete(buf, {force = true})
end

return M
