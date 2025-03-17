local utils = require("cuda-prof.utils")

---@class CudaProfUI
---@field win_id number
---@field status boolean
---@field bufnr number
---@field config CudaProfWindowConfig
---@field open_menu fun(opts: CudaProfWindowConfig): nil
---@field close_menu fun(): nil
---@field create_buffer fun(keymap: fun(bufnr: integer): nil): nil
---@field import fun(opts: CudaProfSessionConfig): nil
---@field save fun(): nil
local M = {}

---@private
function M.close_menu()
    if not M.status then
        return
    end
    if M.bufnr ~= nil and vim.api.nvim_buf_is_valid(M.bufnr) and M.win_id ~= nil and vim.api.nvim_win_is_valid(M.win_id) then
        --- check if the contents are valid with the manager
        vim.api.nvim_win_close(M.win_id, true)
    end
    M.win_id = nil
    M.status = false
end

--- Opens the interactive session
---@private
---@param opts CudaProfWindowConfig
---@return nil
function M.open_menu(opts)
    if M.status then
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

---@private
---@param opts CudaProfWindowConfig
---@return CudaProfWindowConfig
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

---@private
---@param keymap fun(bufnr: integer): nil?
---@return number
function M.create_buffer(keymap)
    local bufnr = vim.api.nvim_create_buf(false, true)
    M.setup_autocmds_and_keymaps(bufnr, keymap)
    return bufnr
end

--- Auto command that imports the history to a newly created buffer on VimEnter
---@param opts CudaProfSessionConfig
function M.import(opts)
    M.create_buffer(opts.keymaps)
    --- feed with the history
    --- check history of changes
    --- Log information
end

--- Implements saving into .cuda-prof_history (VimLeave)
function M.save()
    --- Get all lines from buffer
    --- Check all lines from buffer
    --- Filter all lines from buffer
    --- Overwrite into history
end

---@private
local CudaProfGroup = vim.api.nvim_create_autocmd("CudaProf", {})

---@private
---@param bufnr number
---@param keymaps fun(bufnr: integer): nil?
function M.setup_autocmds_and_keymaps(bufnr, keymaps)
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

    --- Define the keymap function
    if keymaps ~= nil then
        keymaps(bufnr)
    end

    --- CHANGE ALL OF THIS
    --- Define other autocmds
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = CudaProfGroup,
        buffer = bufnr,
        callback = function()
            local config = require("cuda-prof").config
            require("cuda-prof.sessions.ui").save()
        end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = CudaProfGroup,
        buffer = bufnr,
        callback = function()
            -- Content checking and possible warning, maybe ignore not valid filepath on trigger with warning (on close)
            require("cuda-prof.sessions").ui:save()
        end,
    })
end

return M
