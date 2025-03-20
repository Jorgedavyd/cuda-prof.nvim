---@class Nsight
---@field config NsightConfig
---@field setup fun(opts: NsightConfig):nil
---@field status boolean
local M = {}

_G.status = false

---@param opts? NsightConfig
function M.setup(opts)
    require("nsight.config").setup(opts)
    require("nsight.autocmd").setup()
    require("nsight.triggers").setup()
end

return setmetatable(M, {
    __index = function(_, k)
        return require("nsight.api")[k]
    end,
})
