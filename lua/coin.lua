local util = require('util')

local api = vim.api
local ns = api.nvim_create_namespace('Normal')

local M = {}
local is_enable = false

-- highlight
api.nvim__set_hl_ns(ns)
api.nvim_set_hl(ns, 'Coin', {fg = 'yellow'})

local coin_num = 0
local coins = {}
local total_coin_buf, total_coin_win

-- constants
local COIN_FRAMES = "▁▇█│█│█│█"
local FRAME_MAX = 10 + 1

-- total coin
local function create_total_coin_window()
    local win_opts = {
        relative = 'editor',
        width = 14,
        height = 1,
        col = vim.fn.winwidth(0) - 14,
        row = 0,
        focusable = false,
        style = 'minimal',
    }
    local buf, win = util.create_floating_win(win_opts)
    api.nvim_win_set_option(win, 'winblend', 30)
    return buf, win
end

local function update_total_coin()
    local s = string.format(' ● x %08d', coin_num)
    api.nvim_buf_set_lines(total_coin_buf, 0, 1, true, {s})
    api.nvim_buf_add_highlight(total_coin_buf, ns, 'Coin', 0, 2, 5)
end

local Coin = {}

function Coin.new(id, x, y, buf, win)
    local obj = {}
    obj.id = id
    obj.buf = buf
    obj.win = win
    obj.x = x
    obj.y = y
    obj.count = 0
    setmetatable(obj, {__index = Coin})
    return obj
end

function Coin:update(t)
    local frame_start = self.count * 3 + 1
    local frame_end = frame_start + 2

    self.count = self.count + 1
    if self.count == 3 then
        local y, x = util.get_curpos()
        api.nvim_win_set_config(self.win, {
                relative = 'cursor',
                col = self.x - x,
                row = self.y - y - 2,
        })
    end
    if self.count == FRAME_MAX then
        api.nvim_win_close(self.win, true)
        api.nvim_buf_delete(self.buf, { force = true })
        coins[self.id] = nil
        return
    end

    api.nvim_buf_set_lines(self.buf, 0, 1, true, {COIN_FRAMES:sub(frame_start, frame_end)})
    api.nvim_buf_add_highlight(self.buf, ns, 'Coin', 0, 0, -1)
end

function Coin:start()
    vim.fn.timer_start(55, function(timer)
        self:update(timer)
    end, {['repeat'] = FRAME_MAX})
end

local function create_coin_window()
    local win_opts = {
        relative = 'cursor',
        width = 1,
        height = 1,
        col = 0,
        row = -1,
        focusable = false,
        style = 'minimal',
    }
    local buf, win = util.create_floating_win(win_opts)
    api.nvim_win_set_option(win, 'winblend', 100)
    return buf, win
end

local function create_coin()
    local buf, win = create_coin_window()
    local y, x = util.get_curpos()
    local coin = Coin.new(coin_num, x, y, buf, win)
    coins[coin_num] = coin
    -- start animation
    coin:start()
    if is_enable then
        coin_num = coin_num + 1
        update_total_coin()
    end
end

local function add_keymap()
    for i = 0x21, 0x7f do
        api.nvim_set_keymap('i', string.char(i), string.char(i) .. '<ESC>:lua require("coin").create_coin()<CR>a', {silent=true, noremap=true})
    end
end

local function del_keymap()
    for i = 0x21, 0x7f do
        api.nvim_del_keymap('i', string.char(i))
    end
end

local function enable_coin()
    if is_enable then
        return
    end
    -- create total coin window
    total_coin_buf, total_coin_win = create_total_coin_window()
    update_total_coin()
    -- add keymap
    add_keymap()
    is_enable = true
end

local function disable_coin()
    if not is_enable then
        return
    end
    -- coin
    coin_num = 0
    coins = {}
    -- total coin window
    api.nvim_win_close(total_coin_win, true)
    api.nvim_buf_delete(total_coin_buf, { force = true })
    -- delete keymap
    del_keymap()
    is_enable = false
end

M.create_coin = create_coin
M.enable_coin = enable_coin 
M.disable_coin = disable_coin 

return M