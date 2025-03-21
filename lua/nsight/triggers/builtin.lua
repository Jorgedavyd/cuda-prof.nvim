local wrapper = require("nsight.wrapper")
local trigger = require("nsight.triggers.init")
local sequences = require("nsight.triggers.sequences")

---@class NsightBuiltinTrigger
---@field nvcc_nsys NsightTriggers
---@field nvcc_ncu NsightTriggers
---@field nvcc_nvvp NsightTriggers
---@field nvcc NsightTriggers
local M = {}

M.nvcc_nsys = trigger:new(sequences:new({
    function ()
        wrapper.nvcc("")
    end
}))

M.nvcc_ncu = trigger:new(sequences:new({
    function ()
    end
}))

M.nvcc_nvvp = trigger:new(sequences:new({
    function ()
    end
}))

M.nvcc = trigger:new(sequences:new({
    function ()
    end
}))


return M
