local utils = require("nsight.utils")
local config = require("nsight.config").opts

---@private
---@class NsightToolWrapper
---@field private new fun(self, basecmd: string):NsightToolWrapper
---@field private basecmd string
---@field __call fun(self, args: string|[string]):nil
---@field ui fun(self, args: string):nil
local W = {}

function W:new(basecmd)
    local instance = {
        basecmd = basecmd
    }
    return setmetatable(instance, { __index = self })
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

local function parse_args(cmd, args)
    if type(args) == "string" then
        args = string.split(args, " ")
    end
    local result = {cmd}
    vim.list_extend(result, args)
    return result
end

function W:__call(args)
    local cmd = parse_args(self.basecmd, args or {})
    vim.system(cmd, {text = true}, function(out)
        if out.code == 0 then
            utils.LogInfo(string.format("%s ran successfully.", self.basecmd))
            vim.notify(out.stdout, vim.log.levels.INFO)
        else
            utils.LogError(string.format("%s failed with error code %s.", self.basecmd, out.code))
            vim.notify(out.stderr, vim.log.levels.ERROR)
        end
    end)
end

function W:ui(args)
    utils.LogNotImplemented("UI not implemented for this command")
end

---@class NsightWrapper
---@field tools [string]
---@field setup fun():nil
---@field nvcc NsightWrapper
---@field ncu NsightWrapper
---@field nsys NsightWrapper
---@field nvvp NsightWrapper
local M = {}
M.tools = {"nvcc", "ncu", "nvvp", "nsys"}

function M.setup()
    local opts = config.extensions.cli or nil
    if opts ~= nil then
        vim.list_extend(M.tools, opts)
    end

    for _, tool in ipairs(M.tools) do
        M[tool] = W:new(tool)
    end

    if M.ncu then
        function M.ncu.ui(args)
            local wrap = W:new("ncu-ui")
            return wrap(args)
        end
    end

    if M.nsys then
        function M.nsys.ui(args)
            local wrap = W:new("nsys-ui")
            return wrap(args)
        end
    end
end

return M
