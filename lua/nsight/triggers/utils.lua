---@class NsightTriggerUtils
---@field binaryFromFilepath fun(project: string):string
---@field reportFromFilepathAndReportNumber fun(basepath: string, project: string, cmd: string):string
local M = {}

function M.binaryFromFilepath(project)
    return vim.split(vim.fs.basename(project), ",")[1]
end

function M.reportFromFilepathAndReportNumber(basepath, project, cmd)
    local type_extension = string.format(cmd, "-rep")
    return vim.fn.resolve(basepath .. "/" .. vim.fs.basename(project) "/" .. type_extension)
end

return M
