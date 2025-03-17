---@class CudaProf
---@field config CudaProfConfig
---@field setup fun(opts: CudaProfConfig):nil
---@field status boolean
local M = {}

---@param opts? CudaProfConfig
function M.setup(opts)
  require("cuda-prof.config").setup(opts)
  require("cuda-prof.user_cmds").setup()
end

return setmetatable(M, {
  __index = function(_, k)
    return require("cuda-prof.api")[k]
  end,
})
