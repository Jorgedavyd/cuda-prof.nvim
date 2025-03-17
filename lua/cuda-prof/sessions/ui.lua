local utils = require("cuda-prof.utils")
local broker = require("cuda-prof.sessions.broker")

---@class CudaProfWindowConfig
---@field border? any this value is directly passed to nvim_open_win
---@field title_pos? any this value is directly passed to nvim_open_win
---@field title? string this value is directly passed to nvim_open_win
---@field height_in_lines? number this value is directly passed to nvim_open_win
---@field width_in_columns? number this value is directly passed to nvim_open_win
---@field style? string this value is directly passed to nvim_open_win

---@class CudaProfUI
---@field win_id number
---@field status boolean
---@field buf_id number
---@field config CudaProfWindowConfig
local M = {}

M.__index = M

---@param config CudaProfWindowConfig
---@return CudaProfUI
function M:new(config)
    return setmetatable({
        win_id = nil,
        status = 0,
        bufnr = nil,
        config = config,
    }, self)
end

function M:close_menu()
    if not self.status then
        return
    end
    if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_close(self.win_id, true)
    end

    self.win_id = nil
    self.bufnr = nil
    self.status = false
end

---@param opts CudaProfWindowConfig
---@return number,number
function M:_create_window(opts)
    local width = opts.width_in_columns
    local height = opts.height_in_lines or 8
    local bufnr = vim.api.nvim_create_buf(false, true)
    opts.width_in_columns = nil
    opts.height_in_lines = nil
    opts = vim.tbl_deep_extend('error', {
        relative = "editor",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
    }, opts)
    local win_id = vim.api.nvim_open_win(bufnr, true, opts)

    if win_id == 0 then
        utils.LogError("ui:_create_window failed to create window, win_id returned 0\n Failed to create window")
        self.bufnr = bufnr
    end

    broker.setup_autocmds_and_keymaps(bufnr, opts)

    self.win_id = win_id
    vim.api.nvim_set_option_value("number", true, {
        win = win_id,
    })

    return win_id, bufnr
end

---@param list? HarpoonList
---TODO: @param opts? CudaProfWindowConfig
function M:toggle_quick_menu(list, opts)
    opts = opts or {}
    local current_file = vim.api.nvim_buf_get_name(0)
    local win_id, bufnr = self:_create_window(opts)

    self.win_id = win_id
    self.bufnr = bufnr

    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, list)
end

function M:_get_processed_ui_contents()
    local list = broker.get_contents(self.bufnr)
    local length = #list
    return list, length
end

function M:save()
    local list, length = self:_get_processed_ui_contents()

    Logger:log("ui#save", list)
    self.active_list:resolve_displayed(list, length)
    if self.config.sync_on_ui_close then
        require("harpoon"):sync()
    end
end

---@param config CudaProfWindowConfig
function M:configure(config)
    self.config = config
end

return M
