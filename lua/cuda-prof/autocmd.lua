local group = require("cuda-prof.augroup")
local wrappers = require("cuda-prof.wrapper")
local config = require("cuda-prof.config").opts
local ui = require("cuda-prof.ui")
local utils = require("cuda-prof.utils")

---@class CudaProfNvimWrapper
---@field private activate fun():nil
---@field private deactivate fun():nil
---@field private toggle fun():nil
---@field setup fun():nil
local M = {}

function M.activate()
    if _G.status then
        utils.LogInfo("The Cuda Profiler is active already")
        return
    end
    _G.status = true
    ui.import()
end

function M.deactivate()
    if not _G.status then
        utils.LogInfo("The Cuda Profiler was deactivated already")
        return
    end
    _G.status = false
    ui.save()
end

function M.toggle()
    if _G.status then
        M.deactivate()
        return
    end
    M.activate()
end

local function transform_cmd_to_regex(cmd)
    if type(cmd) ~= "string" or cmd == "" then
        return ""
    end
    local result = cmd:sub(1, 1):upper() .. cmd:sub(2)
    result = result:gsub("-(%l)", function(letter)
        return letter:upper()
    end)
    return result
end

function M.setup()
    vim.api.nvim_create_autocmd({"BufferEnter", "BufferLeave"},{
        group = group,
        pattern = {"*.cu", "*.cuh"},
        callback = function (event)
            vim.api.nvim_buf_create_user_command(
                event.buf,
                "CudaProfilerDeactivate",
                "lua require('cuda-prof').deactivate()",
                {}
            )

            vim.api.nvim_buf_create_user_command(
                event.buf,
                "CudaProfilerActivate",
                "lua require('cuda-prof').activate()",
                {}
            )

            vim.api.nvim_buf_create_user_command(
                event.buf,
                "CudaProfilerToggle",
                "lua require('cuda-prof').toggle()",
                {}
            )

            for _, cmd in ipairs(wrappers.tools) do
                local user_cmd = transform_cmd_to_regex(cmd)
                vim.api.nvim_create_user_command(
                    user_cmd,
                    string.format("lua require('cuda-prof.wrappers')[%s]", cmd),
                    {}
                )
            end

            config.keymaps(event.buf)
        end
    })
end

return M
