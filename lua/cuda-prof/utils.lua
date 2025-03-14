---@class CudaNotifications
---@field LogError fun(msg: string): nil
---@field LogWarning fun(msg: string): nil
---@field LogInfo fun(msg: string): nil
---@field LogNotImplemented fun(msg: string): nil
local M = {}

setmetatable(M,
    {
        __index = function (_, key)
            return function (msg)
                vim.notify(msg, vim.log.levels[key], {})
            end
        end
    }
)

---CudaNotifications.LogError: Notifies the user of an error.
---@param msg string
---@return nil
function M.LogError(msg)
    msg = string.format("CudaProf -> %s ❌", msg)
    vim.notify(msg, vim.log.levels.ERROR, {})
end

---CudaNotifications.LogNotImplemented: Notifies the user of a not implemented error.
---@param f string
---@return nil
function M.LogNotImplemented(f)
    local msg = string.format("%s is not a valid attribute within cuda-prof.nvim, check the docs. ❌", f)
    vim.notify(msg, vim.log.levels.ERROR, {})
end

---CudaNotifications.LogWarning: Notifies the user of a runtime warning.
---@param msg string
---@return nil
function M.LogWarning(msg)
    msg = string.format("CudaProf -> %s ⚠", msg)
    vim.notify(msg, vim.log.levels.WARN, {})
end

---CudaNotifications.LogInfo: Notifies the user of a runtime info.
---@param msg string
---@return nil
function M.LogInfo(msg)
    msg = string.format("CudaProf -> %s ✓", msg)
    vim.notify(msg, vim.log.levels.INFO, {})
end

return M
