local wrapper = require("cuda-prof.wrapper")

---@class CudaProfBuiltinTriggers
---@field private wrapper_ fun():nil
---@field __call fun():nil

---@type CudaProfBuiltinTriggers
local nsys_trigger = {
    wrapper_ = wrapper.nsys.__call,
    __call = function()
    end
}

---@type CudaProfBuiltinTriggers
local nvcc_trigger = {
    wrapper_ = wrapper.nvcc.__call,
    __call = function()
    end
}

---@type CudaProfBuiltinTriggers
local ncu_trigger = {
    wrapper_ = wrapper.ncu.__call,
    __call = function()
        self.wrapper_()
    end
}

return {
    nvcc_trigger = nvcc_trigger,
    ncu_trigger = ncu_trigger,
}
