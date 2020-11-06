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
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, {force = true})
  end
end

M.lsp = function(query, type)
  local params = vim.lsp.util.make_position_params()
  params.query = ""
  params.context = {includeDeclaration = true}
  local timeout = 10000
  local symbols = vim.lsp.buf_request_sync(0, query, params, timeout)
  for _, res in pairs(symbols) do
    local items
    if type == "symbols" then
      items = vim.lsp.util.symbols_to_items(res.result, 0)
    else
      items = vim.lsp.util.locations_to_items(res.result, 0)
    end
    for _, symbol in pairs(items) do
      if not string.match(symbol.text, "<Anonymous>$") then
        print(symbol.text, symbol.filename, symbol.lnum)
      end
    end
  end
end

return M
