---@class NsightNotifications
---@field LogError fun(msg: string): nil
---@field LogWarning fun(msg: string): nil
---@field LogInfo fun(msg: string): nil
---@field LogNotImplemented fun(msg: string): nil
local M = {}

setmetatable(M,
    {
        __index = function (_, key)
            return function (msg)
                msg = string.format("Nsight -> %s ", msg)
                vim.notify(msg, vim.log.levels[key], {})
            end
        end
    }
)

function M.LogError(msg)
    msg = string.format("Nsight -> %s ❌", msg)
    vim.notify(msg, vim.log.levels.ERROR, {})
end

function M.LogNotImplemented(f)
    local msg = string.format("%s is not a valid attribute within nsight.nvim, check the docs. ❌", f)
    vim.notify(msg, vim.log.levels.ERROR, {})
end

function M.LogWarning(msg)
    msg = string.format("Nsight -> %s ⚠", msg)
    vim.notify(msg, vim.log.levels.WARN, {})
end

function M.LogInfo(msg)
    msg = string.format("Nsight -> %s ✓", msg)
    vim.notify(msg, vim.log.levels.INFO, {})
end

return M
