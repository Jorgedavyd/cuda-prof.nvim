local config = require("cuda-prof.config").config
local uv = vim.loop or vim.uv

---@class CudaProfProjectManager Basically manages all IO operations and setting up experiments.
---@field new fun(self):CudaProfProjectManager
---@field project_path string
---@field setup fun(self, opts: table): nil Sets up the projects.
---@field sequence_trigger fun(self, filepaths: [string]): nil Creates the IO accessibility for the sequence trigger.
local M = {}
M.__index = M

function M:new()
    local project_path
    local cuda_prof = {
        project_path = project_path,
    }
    setmetatable(cuda_prof, self)
    self.project_path = self:resolve_project_path()
    return cuda_prof
end

---@param filepaths [string]
---@return nil
function M:sequence_trigger(filepaths)
    local resolved_name = self:resolveExperimentName(filepaths)
    local hyp_dir = vim.fn.resolve(self:resolveExperimentsPaths(vim.fn.resolve(self.project_path .. "/.cuda-prof.nvim") .. resolved_name)
    if vim.fn.isdirectory(hyp_dir) ~= 1 then
        uv.fs_mkdir(hyp_dir)
        uv.fs_mkdir(vim.fn.resolve(hyp_dir .. "/report1"))
        return
    end
    local new_report = self:resolveNewReport(filepaths)
    uv.fs_mkdir(new_report)
end

---@private
---@return string
function M:resolve_project_path()
    local current_dir = vim.fn.getcwd()
    local resolved_project = current_dir
    for _, trigger in pairs(config.session.resolve_triggers) do
        local dir = current_dir
        while dir and dir ~= "" do
            local trigger_path = dir .. "/" .. trigger
            if vim.fn.isdirectory(trigger_path) == 1 or vim.fn.filereadable(trigger_path) == 1 then
                resolved_project = dir
                return resolved_project
            end
            local parent_dir = vim.fn.fnamemodify(dir, ":h")
            if parent_dir == dir then
                break
            end
            dir = parent_dir
        end
    end
    return resolved_project
end

---@private
---@param resolved_filepaths [string]
---@return string
function M:resolveExperimentName(resolved_filepaths)
    local ordered = vim.fn.sort(resolved_filepaths)
    local names = vim.tbl_map(function(k) return vim.fs.basename(k) end, ordered) --- probably got to implement a better way
    return table.concat(names, "_")
end

---@private
---@param cudaProfPath string
---@return string
function M:resolveExperimentsPaths(cudaProfPath)
    return vim.fn.resolve(cudaProfPath .. "/experiments")
end

---@private
---@return string
function M:resolveCudaProfPath()
    return vim.fn.resolve(self.project_path .. "/.cuda-prof.nvim")
end

---@private
---@param filepaths [string]
---@return string
function M:resolveExperimentPath(filepaths)
    local experiment_path = self:resolveExperimentsPaths(
        vim.fn.resolve(self.project .. "/.cuda-prof/experiments")
    )
    local experiment_name = self:resolveExperimentName(filepaths)
    return vim.fn.resolve(experiment_path .. experiment_name)
end

---@private
---@param filepaths [string]
---@return string
function M:resolveExperimentHistoryPath(filepaths)
    local experiment_path = self:resolveExperimentPath(filepaths)
    return vim.fn.resolve(experiment_path .. "/.history")
end

function M:resolveNewReport(filepaths)
    local experiment = self:resolveExperimentPath(filepaths)
    local query = "report*"
    local num = #vim.fn.globpath(experiment, query)
    num = num + 1
    return vim.fn.resolve(experiment .. "report" .. num)
end

--- This functions sets up the .cuda-prof.nvim workflow in the current project
function M:setup()
    uv.fs_mkdir(self.project_path)
    local experiment_path = self:resolveExperimentsPaths(vim.fn.resolve(self.project_path .. "/cuda-prof.nvim"))
    uv.fs_mkdir(experiment_path)
end

return M
