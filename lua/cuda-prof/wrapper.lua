local utils = require("cuda-prof.utils")
local config = require("cuda-prof.config").opts

---@private
---@class NsightToolWrapper
---@field private new fun(self, basecmd: string):NsightToolWrapper
---@field private basecmd string
---@field __call fun(self, args: string|[string]):nil
---@field ui fun(self, args: string):nil
local W = {}

function W:new(basecmd)
    setmetatable(W, self)
    self.basecmd = basecmd
    return self
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function parse_args(k, args)
    if type(string) == "table" then
        args = string.split(args, " ")
    end
    local cmd = {k}
    vim.list_extend(cmd, args)
    return cmd
end

setmetatable(W,{
    __index = function (_, k)
        if k == "ui" then
            utils.LogNotImplemented("UI not implemented for this command")
            return
        elseif k == "__call" then
            return function(args)
                local cmd  = parse_args(k, args)
                vim.system(cmd, {text = true}, function (out)
                    if out.code == 0 then
                        utils.LogInfo(string.format("%s ran succesfully.", k))
                        vim.notify(out.stdout, vim.log.levels.INFO)
                        return
                    else
                        utils.LogInfo(string.format("%s failed with error code %s.", k, out.code))
                        vim.notify(out.stderr, vim.log.levels.ERROR)
                        return
                    end
                end)
            end
        else
            utils.LogError("Not a valid field")
            return
        end
    end
})


---@class NsightWrapper
---@field tools [string]
---@field setup fun():nil
local M = {}

M.tools = {"nvcc", "ncu", "nvvp", "nsys"}

function M.setup()
    local opts = config.extensions.cli or nil
    if opts ~= nil then
        vim.list_extend(M.tools, opts)
    end
    M = vim.tbl_extend("keep", M, vim.tbl_map(function (value) return W:new(value) end, M.tools))
    function M.ncu.ui(args)
        local wrap = W:new("ncu-ui")
        return wrap(args)
    end
    function M.nsys.ui(args)
        local wrap = W:new("nsys-ui")
        return wrap(args)
    end
end


return M
