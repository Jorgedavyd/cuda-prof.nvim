local trigger = require("nsight.triggers.init")
local utils = require("nsight.utils")
local sequences = require("nsight.triggers.sequences")

---@alias NsightBuiltinTrigger fun(opts: table<string, string>): NsightTriggers

---@type NsightBuiltinTrigger
return setmetatable({}, {
    __index = function(_, k)
        local methods = vim.split(k, "_")
        if #methods > 0 then
            return function(opts)
                return trigger:new(sequences:new(vim.tbl_map(function(value)
                    local sampled_method = vim.split(value, "-")
                    local wrap = require("nsight.wrapper")
                    for _, part in ipairs(sampled_method) do
                        if wrap and wrap[part] then
                            wrap = wrap[part]
                        else
                            utils.LogError("Invalid method: " .. value)
                            return nil
                        end
                    end
                    return wrap and wrap(opts)
                end, methods)))
            end
        end
    end
})

