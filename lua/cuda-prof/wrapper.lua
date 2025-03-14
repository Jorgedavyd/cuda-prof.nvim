---@class CudaProfilerWrapper
---@field nvcc NvccWrapper
---@field nsys NvidiaSystemsWrapper
---@field ncu NvidiaComputeWrapper
---@field nvvp NvidiaVisualProfilerWrapper

---@class NvccWrapper
---@field nvccCompile fun(args: string):nil

---@class NvidiaSystemsWrapper
---@field nsysTracing fun(args: string):nil
---@field nsysUI fun(args: string):nil

---@class NvidiaComputeWrapper
---@field ncuTracing fun(args: string):nil
---@field ncuUI fun(args: string):nil

---@class NvidiaVisualProfilerWrapper
---@field nvvpTracing fun(args: string):nil
---@field nvvpUI fun(args: string):nil

local utils = require("cuda-prof.utils")

---@type CudaProfilerWrapper
local M = {}

setmetatable(M,{
    __index = function (_, k)
        if vim.tbl_contains(M, k, {predicate = true}) then
            local M_ = {}
            setmetatable(M_,{
                __index = function (_, k_)
                    return function ()
                        utils.LogNotImplemented(k_)
                    end
                end
            })
            return M_
        end
    end
})

return M
