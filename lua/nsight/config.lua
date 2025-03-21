---@class NsightConfigManager
---@field opts NsightConfig
---@field setup fun(opts: NsightConfig?): nil
local M = {}

---@class NsightConfig
---@field session NsightSessionConfig
---@field extensions NsightExtensionConfig
---@field keymaps fun(buf): nil Configure the keymaps on CUDA file attachement.
---@field user_args NsightUserArgs

---@class NsightUserArgs
---@field nvcc table<string, string>
---@field nvvp table<string, string>
---@field ncu table<string, string>
---@field nsys table<string, string>

---@class NsightExtensionConfig
---@field cli [string]

---@class NsightSessionConfig
---@field window NsightWindowConfig
---@field keymaps fun(bufnr: integer): nil
---@field resolve_triggers [string]

---@class NsightWindowConfig
---@field border? any this value is directly passed to nvim_open_win
---@field title_pos? any this value is directly passed to nvim_open_win
---@field title? string this value is directly passed to nvim_open_win
---@field height_in_lines? number this value is directly passed to nvim_open_win
---@field width_in_columns? number this value is directly passed to nvim_open_win
---@field style? string this value is directly passed to nvim_open_win

M.opts = {
    session = {
        window = {
            title = "Nsight Session",
            title_pos = "left",
            width_in_columns = 12,
            height_in_lines = 8,
            style = "minimal",
            border = "single"
        },
        keymaps = function (bufnr)
            vim.keymap.set("n", "<leader>cu", "echo Hola", {buffer = bufnr})
        end,
        resolve_triggers = {}
    },
    extensions = {
        cli = {}
    },
    keymaps = function (bufnr)
        vim.keymap.set("n", "<leader>cu", "echo Hola", {buffer = bufnr})
    end,
    user_args = {
        nvcc = {},
        nsys = {},
        ncu = {},
        nvvp = {},
    }
}


function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_deep_extend('keep', opts, M.opts)
end

return M
