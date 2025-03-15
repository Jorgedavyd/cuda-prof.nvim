local utils = require("cuda-prof.utils")

---@class CudaProfWrapper
---@field nvcc NvccWrapper
---@field nsys NvidiaSystemsWrapper
---@field ncu NvidiaComputeWrapper
---@field nvvp NvidiaVisualProfilerWrapper

---@class Report
---@field path string
---@field check fun(arg: string):boolean

---@class NvccWrapper
---@field __call fun(args: string):nil
---@field defaults {ui: fun(report: Report):nil; trace: fun(file: string):nil}

---@class NvidiaSystemsWrapper
---@field __call fun(args: string):nil
---@field defaults {ui: fun(report: Report):nil; trace: fun(file: string):nil}

---@class NvidiaComputeWrapper
---@field __call fun(args: string):nil
---@field defaults {ui: fun(report: Report):nil; trace: fun(file: string):nil}

---@class NvidiaVisualProfilerWrapper
---@field __call fun(args: string):nil
---@field defaults {ui: fun(report: Report):nil; trace: fun(file: string):nil}

---@type CudaProfWrapper
local M = {}

local tools = {"nvcc", "ncu", "nvvp", "nsys"}

setmetatable(M,{
    __index = function (_, k_)
        if vim.list_contains(tools, k_) then
            local M_ = {}
            setmetatable(M_, {
                __index = function (_, k)
                    utils.LogNotImplemented(k)
                end,
                __call =  function(args)
                    local cmd = k_ .. " " .. args
                    utils.LogInfo("Running: " .. cmd)
                    vim.fn.jobstart(cmd, {
                        on_exit = function(_, code)
                            if code == 0 then
                                utils.LogInfo("Compilation succeeded")
                            else
                                utils.LogError("Compilation failed with code " .. code)
                            end
                        end,
                    })
                end
            })
            return M_
        else
            utils.LogNotImplemented(k_)
        end
    end
})

return M
