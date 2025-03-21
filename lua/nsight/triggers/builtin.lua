local trigger = require("nsight.triggers.init")
local utils = require("nsight.utils")
local sequences = require("nsight.triggers.sequences")

---@alias NsightBuiltinTrigger fun(opts: table<string, string>): NsightTriggers

---@type NsightBuiltinTrigger
return setmetatable({}, {
    __index = function (_, k)
        local methods = vim.split(k, "_")
        if methods ~= nil and #methods ~=0 then
            return function (opts)
                return trigger:new(sequences:new(vim.tbl_map(function (value)
                    local wrap = require("nsight.wrapper")[value]
                    return wrap and wrap(opts) or utils.LogError("Not a valid field")
                end, methods)))
            end
        end
    end
})
