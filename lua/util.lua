local M = {}
local api = vim.api

M.get_curpos = function ()
    local pos = api.nvim_win_get_cursor(0)
    return pos[1], pos[2]
end

M.create_floating_win = function (opts)
    local buf = api.nvim_create_buf(false, true)
    local win = api.nvim_open_win(buf, false, opts)
    return buf, win
end

return M