local ui = require("cuda-prof.sessions.ui")
local config = require("cuda-prof.config").config
local wrappers = require("cuda-prof.wrapper")

---@class CudaProfManager
---@field activate fun():nil
---@field deactivate fun():nil
---@field toggle fun():nil
---@field setup fun():nil
local M = {}
M.status = false

function M.activate()
    M.status = true
    ui.import(config.session)
end

function M.deactivate()
    M.status = false
    ui.save()
end

function M.toggle()
    if M.status then
        M.deactivate()
        return
    end
    M.activate()
end

function M.setup()
    vim.api.nvim_create_user_command(
        "CudaProfilerDeactivate",
        "lua require('cuda-prof').deactivate()",
        {}
    )

    vim.api.nvim_create_user_command(
        "CudaProfilerActivate",
        "lua require('cuda-prof').activate()",
        {}
    )

    vim.api.nvim_create_user_command(
        "CudaProfilerToggle",
        "lua require('cuda-prof').toggle()",
        {}
    )

    for _, cmd in ipairs(wrappers.tools) do
        local user_cmd = cmd:gsub("^%l", string.upper)
        vim.api.nvim_create_user_command(
            user_cmd,
            string.format("lua require('cuda-prof.wrappers')[%s]", cmd),
            {}
        )
    end

end

return M
