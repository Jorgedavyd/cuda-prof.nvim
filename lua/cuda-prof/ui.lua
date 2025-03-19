local utils = require("cuda-prof.utils")
local config = require("cuda-prof.config").config
local manager = require("cuda-prof.manager")

---@class CudaProfUI
---@field win_id number
---@field bufnr number
---@field mng CudaProfProjectManager
---@field open_menu fun(opts: CudaProfWindowConfig): nil
---@field close_menu fun(): nil
---@field create_buffer fun(keymap: fun(bufnr: integer): nil): nil
---@field import fun(opts: CudaProfSessionConfig): nil
---@field save fun(): nil Implements saving into .cuda-prof_history (VimLeave)
---@field toggle_quick_menu fun(opts: CudaProfWindowConfig):nil
---@field private getWindowOpts fun(opts: CudaProfWindowConfig): vim.api.keyset.win_config
---@field private create_buffer fun(keymap: (fun(bufnr: integer):nil)?):number
---@field private setup_autocmds_and_keymaps fun(bufnr: integer, keymaps: (fun(bufnr: integer): nil)?):nil
local M = {}

function M.toggle_quick_menu(opts)
    M.open_menu(opts)
    M.close_menu()
end

function M.close_menu()
    if not _G.status then
        return
    end
    if M.bufnr ~= nil and vim.api.nvim_buf_is_valid(M.bufnr) and M.win_id ~= nil and vim.api.nvim_win_is_valid(M.win_id) then
        local lines = vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false)
        local _ = M.mng:check_filepaths(lines)
        vim.api.nvim_win_close(M.win_id, true)
    end
    M.win_id = nil
    _G.status = false
end

function M.open_menu()
    local opts = config.session.window
    if _G.status then
        return
    end
    local win_id
    if M.bufnr ~= nil and vim.api.nvim_buf_is_valid(M.bufnr) then
        win_id = vim.api.nvim_open_win(M.bufnr, true, M.getWindowOpts(opts))
    end
    if win_id == 0 or win_id == nil then
        utils.LogError("ui:_create_window failed to create window, win_id returned 0\n Failed to create window")
    end
    M.win_id = win_id
    vim.api.nvim_set_option_value("number", true, {
        win = win_id,
    })
end

function M.getWindowOpts(opts)
    local width = opts.width_in_columns
    local height = opts.height_in_lines or 8
    opts.width_in_columns = nil
    opts.height_in_lines = nil
    opts = vim.tbl_deep_extend('error', {
        relative = "editor",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
    }, opts)
    return opts
end

function M.create_buffer(keymap)
    if keymap == nil then
        return
    end
    local bufnr = vim.api.nvim_create_buf(false, true)
    M.setup_autocmds_and_keymaps(bufnr, keymap)
    return bufnr
end


function M.import()
    M.create_buffer(config.session.keymaps)
    local lines = {}
    local ok, err = pcall(function ()
        local file = io.open(M.mng.project_path, "r")
        if file then
            for line in file:lines() do
                table.insert(lines, line)
            end
            file:close()
        end
    end)

    if not ok then
        utils.LogError(err)
        return
    end
    local filtered = M.mng:check_filepaths(lines)
    if filtered == nil then
        utils.LogWarning("Couldn't find valid Cuda files in session")
        return
    end
    vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, filtered)
end

function M.save()
    local contents = vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false)
    local filtered = M.mng:check_filepaths(contents)
    if filtered == nil then
        return
    end
    local mng = manager:new()
    local filepath = vim.fn.resolve(mng.project_path .. "/.cuda-prof/.config")
    local ok, err = pcall(function ()
        local file = io.open(filepath, "w")
        if file then
            for _, line in ipairs(filtered) do
                file:write(line .. "\n")
            end
            file:close()
        end
    end)
    if not ok then
        local msg = string.format("Couldn't write to config file %s", filepath)
        utils.LogError(msg .. err)
        return
    end
    utils.LogInfo("Saved to " .. filepath)
end

function M.setup_autocmds_and_keymaps(bufnr, keymaps)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, "CudaProfilerSession")
    end
    vim.api.nvim_set_option_value("filetype", "cuda-prof", {
        buf = bufnr,
    })
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
    if keymaps ~= nil then
        keymaps(bufnr)
    end
end

return M
