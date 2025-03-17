---@class CudaSessionBroker
---@field keymaps CudaKeymapConfig
---@field private ConjuctiveNvccCompile table
---@field private nsysTracing table
---@field private nsysUI table
---@field private nsysCompile table
local M = {}

local CudaProfGroup = require("cuda-prof.autocmd")

function M.run_select_command()
    ---@type CudaProf
    local cuda = require("cuda-prof")
    cuda.ui:select_menu_item()
end

function M.run_toggle_command(key)
    local cuda = require("cuda-prof")
    cuda.ui:toggle_quick_menu()
end

---@param bufnr number
---@param opts CudaProfConfig
function M.setup_autocmds_and_keymaps(bufnr, opts)
    local curr_file = vim.api.nvim_buf_get_name(0)
    local cmd = string.format(
        "autocmd Filetype cuda-prof "
            .. "let path = '%s' | call clearmatches() | "
            -- move the cursor to the line containing the current filename
            .. "call search('\\V'.path.'\\$') | "
            -- add a hl group to that line
            .. "call matchadd('HarpoonCurrentFile', '\\V'.path.'\\$')",
        curr_file:gsub("\\", "\\\\")
    )
    vim.cmd(cmd)

    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, "CudaProfilerSession")
    end

    vim.api.nvim_set_option_value("filetype", "cuda-prof", {
        buf = bufnr,
    })

    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })

    --- Default keymaps for Cuda Profiler Session
    vim.keymap.set("n", "q", function()
        M.run_toggle_command("q")
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "<Esc>", function()
        M.run_toggle_command("Esc")
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "<CR>", function()
        M.run_select_command()
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("v", "<CR>", function()
        M.run_select_command()
    end, { buffer = bufnr, silent = true })

    opts.config.session.keymaps(bufnr)

    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = CudaProfGroup,
        buffer = bufnr,
        callback = function()
            require("cuda-prof").ui:save()
            vim.schedule(function()
                require("cuda-prof").ui:toggle_quick_menu()
            end)
        end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = CudaProfGroup,
        buffer = bufnr,
        callback = function()
            -- Content checking and possible warning, maybe ignore not valid filepath on trigger with warning
            require("cuda-prof").ui:toggle_quick_menu()
        end,
    })
end

---@param bufnr number
---@return [string]
function M.get_contents(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        table.insert(indices, line)
    end

    return indices
end

function M.set_contents(bufnr, contents)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
end

return M
