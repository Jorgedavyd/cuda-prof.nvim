local utils = require("cuda-prof.utils")

---@class CudaProfConfigManager
---@field opts CudaProfConfig
---@field setup fun(CudaProfConfig): nil
local M = {}

---@class CudaProfConfig
---@field session CudaProfSessionConfig
---@field extensions CudaProfExtensionConfig

---@class CudaProfExtensionConfig
---@field telescope table
---@field sqlite table
---@field cli [string]

---@class CudaProfSessionConfig
---@field window CudaProfWindowConfig
---@field keymaps fun(bufnr: integer): nil
---@field resolve_triggers [string]

---@class CudaProfWindowConfig
---@field border? any this value is directly passed to nvim_open_win
---@field title_pos? any this value is directly passed to nvim_open_win
---@field title? string this value is directly passed to nvim_open_win
---@field height_in_lines? number this value is directly passed to nvim_open_win
---@field width_in_columns? number this value is directly passed to nvim_open_win
---@field style? string this value is directly passed to nvim_open_win

---@type CudaProfConfig
M.opts = {
    ---@type CudaProfSessionConfig
    session = {
        ---@type CudaProfWindowConfig
        window = {
            title = "Cuda Profiler",
            title_pos = "left",
            width_in_columns = 12,
            height_in_lines = 8,
            style = "minimal",
            border = "single"
        },
        keymaps = function (bufnr)
            _ = bufnr
            utils.LogNotImplemented("Session Keymaps")
        end,
        resolve_triggers = {}
    },
    ---@type CudaProfExtensionConfig
    extensions = {
        telescope = {},
        sqlite = {},
        cli = {}
    }
}

---Merges default params with user defines params
---@param opts CudaProfConfig
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('keep', opts, M.opts)
end

return M
