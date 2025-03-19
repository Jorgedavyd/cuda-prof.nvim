local ui = require("cuda-prof.ui")
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
    if handle == nil then
        return
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
                if vim.list_contains(vim.api.nvim_buf_get_lines(ui.bufnr, -1, -1, false), selection) then
                    return
                end
                vim.api.nvim_buf_set_lines(ui.bufnr, -1, -1, false, selection)
            end)
        end
    }):find()
end

M.cuda_prof_open_report = function(opts)
    opts = opts or {}
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
                if vim.list_contains(vim.api.nvim_buf_get_lines(ui.bufnr, -1, -1, false), selection) then
                    return
                end
                vim.api.nvim_buf_set_lines(ui.bufnr, -1, -1, false, selection)
            end)
        end
    }):find()
end

function M.open_experiment()
end

return telescope.register_extension {
    exports = {
        file_add_cuda = M.find_cuda_files,
        nsys_open_report = function (opts)
            M.open_reports(opts)
        end,
        ncu_open_report = function (opts)
            M.open_reports(opts)
        end,
        cuda_prof_open_experiment = M.open_experiment,
    }
}
