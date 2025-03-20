---@class CudaProf
---@field config CudaProfConfig
---@field setup fun(opts: CudaProfConfig):nil
---@field status boolean
local M = {}

_G.status = false

---@param opts? CudaProfConfig
function M.setup(opts)
    require("cuda-prof.config").setup(opts)
    require("cuda-prof").setup()
    require("cuda-prof.autocmd").setup()
    require("cuda-prof.triggers").setup()
end

return setmetatable(M, {
    __index = function(_, k)
        return require("cuda-prof.api")[k]
    end,
})
