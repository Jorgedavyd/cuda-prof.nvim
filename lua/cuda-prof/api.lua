local triggers = require("cuda-prof.triggers")
local ui = require("cuda-prof.sessions.ui")
local config = require("cuda-prof.config").config

---@alias trigger_opts [fun(filepath: string): nil]

---@class CudaProfAPI
---@field toggle_include fun():nil Includes the current buffer's filepath pointer
---@field toggle_view fun():nil Opens the interactive session
---@field def_trigger fun(opts: trigger_opts):nil Opens the interactive session
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

function M.def_trigger(opts)
    return triggers:new(opts)
end

return M
