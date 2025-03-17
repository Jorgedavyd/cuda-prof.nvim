local utils = require("cuda-prof.utils")

---@class CudaProf
---@field config CudaProfConfig
---@field setup fun(opts: CudaProfConfig):nil
---@field status boolean
local M = {}

---@class CudaProfConfig
---@field session CudaProfSessionConfig
---@field extensions CudaProfExtensionConfig

---@class CudaProfExtensionConfig
---@field telescope table
---@field sqlite table

---@class CudaProfSessionConfig
---@field window CudaProfWindowConfig
---@field keymaps fun(bufnr: integer): nil

---@class CudaProfWindowConfig
---@field border? any this value is directly passed to nvim_open_win
---@field title_pos? any this value is directly passed to nvim_open_win
---@field title? string this value is directly passed to nvim_open_win
---@field height_in_lines? number this value is directly passed to nvim_open_win
---@field width_in_columns? number this value is directly passed to nvim_open_win
---@field style? string this value is directly passed to nvim_open_win

setmetatable(M, {
    ---Eithers return the default configuration or an invalid functionality.
    ---@private
    ---@return CudaProfConfig?
    __index = function (_, k)
        if k=="config" then
            return {
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
                    end
                },
                ---@type CudaProfExtensionConfig
                extensions = {
                    telescope = {},
                    sqlite = {}
                }
            }
        else
            utils.LogNotImplemented(k)
            return
        end
    end
})

M.status = false

function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('keep', opts, M.config)
end

function M.activate()
    M.status = true
    require("cuda-prof.sessions.ui").import(M.config.session)
end

function M.deactivate()
    M.status = false
    require("cuda-prof.sessions.ui").save()
end

function M.toggle()
    if M.status then
        M.deactivate()
        return
    end
    M.activate()
end

vim.api.nvim_create_user_command(
    "CudaProfilerDeactivate",
    "lua require('cuda-prof').deactivate()",
    {}
)

vim.api.nvim_create_user_command(
    "CudaProfilerActivate",
    "lua require('cuda-prof').activate()",
    {}
)

vim.api.nvim_create_user_command(
    "CudaProfilerToggle",
    "lua require('cuda-prof').toggle()",
    {}
)

---@class CudaProf
return M
