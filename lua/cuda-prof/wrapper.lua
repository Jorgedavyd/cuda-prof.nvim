local utils = require("cuda-prof.utils")
local config = require("cuda-prof.config").opts

---@class CudaProfWrapper
---@field private new fun(self, basecmd: string):CudaProfWrapper
---@field private basecmd string
---@field __call fun(self, args: string):nil
---@field ui fun(self, args: string):nil
local W = {}

function W:new(basecmd)
    setmetatable(W, self)
    self.basecmd = basecmd
    return self
end

setmetatable(W,{
    __index = function (_, k)
        if k == "ui" then
            utils.LogNotImplemented("UI not implemented for this command")
            return
        elseif k == "__call" then
            return function(args)
                local cmd = k .. " " .. args
                utils.LogInfo("Running: " .. cmd)
                vim.fn.jobstart(cmd, {
                    on_exit = function(_, code)
                        if code == 0 then
                            utils.LogInfo("Compilation succeeded")
                        else
                            utils.LogError("Compilation failed with code " .. code)
                        end
                    end})
                end
        else
            utils.LogError("Not a valid field")
            return
        end
    end
})

local tools = {"nvcc", "ncu", "nvvp", "nsys"}

function setup()
    local opts = config.extensions.cli or nil
    if opts ~= nil then
        vim.list_extend(tools, opts)
    end
end

local wrap = vim.tbl_map(function (value)
    return W:new(value)
end, tools)

function wrap.ncu.ui()
end

function wrap.nsys.ui()
end

function wrap.nvvp.ui()
end

-- define UIs

return M
