local wrapper = require("nsight.wrapper")

---@class NsightBuiltinTriggers
---@field private wrapper_ fun():nil
---@field __call fun():nil

---@type NsightBuiltinTriggers
local nsys_trigger = {
    wrapper_ = wrapper.nsys.__call,
    __call = function()
    end
}

---@type NsightBuiltinTriggers
local nvcc_trigger = {
    wrapper_ = wrapper.nvcc.__call,
    __call = function()
    end
}

---@type NsightBuiltinTriggers
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
