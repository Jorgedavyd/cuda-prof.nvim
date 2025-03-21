local ui = require("nsight.sessions.ui")
local config = require("nsight.config").opts

---@alias trigger_opts [fun(filepath: string): nil]

---@class NsightAPI
---@field toggle_include fun():nil Includes the current buffer's filepath pointer
---@field toggle_view fun():nil Opens the interactive session
local M = {}

function M.toggle_include()
    local filepath = vim.fn.getcwd()
    if vim.endswith(filepath, 'cu') then
        vim.api.nvim_buf_set_lines(ui.bufnr, -1, -1, false, {filepath})
    end
end

function M.toggle_view()
    ui.toggle_quick_menu(config.session.window)
end

return M
