local config = require("nsight.config").opts
local utils = require("nsight.utils")

---@class NsightProjectManager Basically manages all IO operations and setting up experiments.
---@field new fun(self):NsightProjectManager
---@field project_path string
---@field setup fun(self, opts: table): nil Sets up the projects.
---@field sequence_trigger fun(self, filepaths: [string]): nil Creates the IO accessibility for the sequence trigger.
---@field check_filepaths fun(self, filepaths: [string]): nil If the lines check sanity standards
---@field private resolve_project_path fun(self):string
---@field private resolveNewReport fun(self, filepaths: [string]):string
---@field private resolveCudaProfPath fun(self):string
---@field private resolveExperimentName fun(self, resolved_filepaths: [string]):string
---@field private resolveExperimentsPaths fun(self, cudaProfPath: string):string
---@field private resolveExperimentPath fun(self, filepaths: [string]):string
---@field private resolveExperimentHistoryPath fun(self, filepaths: [string]):string
local M = {}
M.__index = M

function M:new()
    local project_path
    local cuda_prof = {
        project_path = project_path,
    }
    setmetatable(cuda_prof, self)
    self.project_path = self:resolve_project_path()
    return self
end

function M:check_filepaths(filepaths)
    return vim.tbl_map(function (line)
        if (vim.fn.filereadable(line)) and (vim.endswith(line, ".cu")) then
            return line
        end
        local msg = string.format("%s is not a valid filepath", line)
        utils.LogWarning(msg)
    end, filepaths)
end

function M:sequence_trigger(filepaths)
    local resolved_name = self:resolveExperimentName(filepaths)
    local cuda_prof_dir = vim.fn.resolve(self.project_path .. "/.nsight.nvim")
    if vim.fn.isdirectory(cuda_prof_dir) ~= 1 then
        vim.fn.mkdir(cuda_prof_dir, "p")
    end
    local experiments_dir = self:resolveExperimentsPaths(cuda_prof_dir)
    if vim.fn.isdirectory(experiments_dir) ~= 1 then
        vim.fn.mkdir(experiments_dir, "p")
    end
    local experiment_dir = vim.fn.resolve(experiments_dir .. "/" .. resolved_name)
    if vim.fn.isdirectory(experiment_dir) ~= 1 then
        vim.fn.mkdir(experiment_dir, "p")
        vim.fn.mkdir(vim.fn.resolve(experiment_dir .. "/report1"), "p")
        return
    end
    local new_report = self:resolveNewReport(filepaths)
    vim.fn.mkdir(new_report, "p")
end

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

function M:resolveExperimentName(resolved_filepaths)
    local ordered = vim.fn.sort(resolved_filepaths)
    local names = vim.tbl_map(function(k) return vim.fs.basename(k) end, ordered) --- probably got to implement a better way
    return table.concat(names, "_")
end

function M:resolveExperimentPath(filepaths)
    local experiment_path = self:resolveExperimentsPaths(
        vim.fn.resolve(self.project_path .. "/.nsight.nvim/experiments")
    )
    local experiment_name = self:resolveExperimentName(filepaths)
    return vim.fn.resolve(experiment_path .. experiment_name)
end

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

function M:resolveExperimentsPaths(cudaProfPath)
    return vim.fn.resolve(cudaProfPath .. "/experiments")
end

function M:resolveCudaProfPath()
    return vim.fn.resolve(self.project_path .. "/.nsight.nvim")
end

function M:setup()
    local cuda_prof_path = self:resolveCudaProfPath()
    if vim.fn.isdirectory(cuda_prof_path) ~= 1 then
        vim.fn.mkdir(cuda_prof_path, "p")
    end

    local experiments_path = self:resolveExperimentsPaths(cuda_prof_path)
    if vim.fn.isdirectory(experiments_path) ~= 1 then
        vim.fn.mkdir(experiments_path, "p")
    end

    local config_path = vim.fn.resolve(cuda_prof_path .. "/.config")
    if vim.fn.filereadable(config_path) ~= 1 then
        local file = io.open(config_path, "w")
        if file then
            file:write("# nsight.nvim configuration\n")
            file:close()
        end
    end
end

return M
