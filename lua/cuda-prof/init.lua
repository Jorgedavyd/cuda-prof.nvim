local utils = require("cuda-prof.utils")

---@class CudaProfConfig
local M = {}

setmetatable(M, {
    ---Eithers return the default configuration or an invalid functionality.
    ---@private
    ---@return CudaProfConfig?
    __index = function (_, k)
        if k=="config" then
            return {
                session = {
                    ---@class CudaSessionWindowConfig
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

function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('keep', opts, M.config)
end

---@class CudaProf
return M
