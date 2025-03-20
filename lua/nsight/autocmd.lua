local group = require("nsight.augroup")
local wrappers = require("nsight.wrapper")
local config = require("nsight.config").opts
local ui = require("nsight.ui")
local utils = require("nsight.utils")

---@class NsightNeovimWrapper
---@field private activate fun():nil
---@field private deactivate fun():nil
---@field private toggle fun():nil
---@field setup fun():nil
local M = {}

function M.activate()
    if _G.status then
        utils.LogInfo("Nsight is active already")
        return
    end
    _G.status = true
    ui.import()
end

function M.deactivate()
    if not _G.status then
        utils.LogInfo("Nsight was deactivated already")
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
                "NsightDeactivate",
                "lua require('nsight').deactivate()",
                {}
            )

            vim.api.nvim_buf_create_user_command(
                event.buf,
                "NsightActivate",
                "lua require('nsight').activate()",
                {}
            )

            vim.api.nvim_buf_create_user_command(
                event.buf,
                "NsightToggle",
                "lua require('nsight').toggle()",
                {}
            )

            for _, cmd in ipairs(wrappers.tools) do
                local user_cmd = transform_cmd_to_regex(cmd)
                vim.api.nvim_create_user_command(
                    user_cmd,
                    string.format("lua require('nsight.wrappers')[%s]", cmd),
                    {}
                )
            end

            config.keymaps(event.buf)
        end
    })
end

return M
