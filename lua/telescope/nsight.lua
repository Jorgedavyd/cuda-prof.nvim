local ui = require("nsight.ui")
local telescope = require("telescope")
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local function find_cuda_files()
    local command = "find . -type f -name '*.cu' -o -name '*.cuh'"
    local handle = io.popen(command)
    if not handle then
        vim.notify("Failed to execute find command for CUDA files", vim.log.levels.ERROR)
        return {}
    end
    local result = handle:read("*a")
    handle:close()
    local files = {}
    for file in string.gmatch(result, "[^\n]+") do
        table.insert(files, file)
    end
    return files
end

M.find_cuda_files = function(opts)
    opts = opts or {}
    assert(ui.bufnr, "cuda-prof.ui buffer not initialized")
    pickers.new(opts, {
        prompt_title = "Add to CUDA Profiler Session",
        finder = finders.new_table {
            results = find_cuda_files(),
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.file_previewer(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                local file = selection[1]  -- Telescope entry value
                if vim.list_contains(vim.api.nvim_buf_get_lines(ui.bufnr, 0, -1, false), file) then
                    return
                end
                vim.api.nvim_buf_set_lines(ui.bufnr, -1, -1, false, { file })
            end)
            return true
        end,
    }):find()
end

local function find_reports(cmd)
    local type_ = string.sub(cmd, 1, -4)
    local command = string.format("find . -name 'report[0-9]+.%s-rep'", type_)
    local handle = io.popen(command)
    if not handle then
        vim.notify("Failed to execute find command for reports", vim.log.levels.ERROR)
        return {}
    end
    local result = handle:read("*a")
    handle:close()
    local files = {}
    for file in string.gmatch(result, "[^\n]+") do
        table.insert(files, file)
    end
    return files
end

M.cuda_prof_open_report = function(title, cmd, opts)
    assert(vim.endswith(cmd, "ui"), "Not a valid cmd")
    opts = opts or {}
    local wrapper = require("nsight.wrapper")
    assert(wrapper[cmd], "No wrapper function for " .. cmd)
    pickers.new(opts, {
        prompt_title = title,
        finder = finders.new_table {
            results = find_reports(cmd),
        },
        previewer = conf.file_previewer(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                wrapper[cmd](selection[1])
            end)
            return true
        end,
    }):find()
end

return telescope.register_extension {
    exports = {
        file_add_cuda = M.find_cuda_files,
        nsys_open_report = function(opts)
            return M.cuda_prof_open_report("Nsight Systems UI", "nsys-ui", opts)
        end,
        ncu_open_report = function(opts)
            return M.cuda_prof_open_report("Nsight Compute UI", "ncu-ui", opts)
        end,
    }
}
