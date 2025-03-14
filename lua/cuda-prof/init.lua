local profiler = require("cuda_tools.profiler")
local utils = require("cuda-prof.utils")

local M = {}

setmetatable(M, {
    ---Eithers return the default configuration or an invalid functionality.
    ---@return CudaConfig|fun(...):any
    __index = function (_, k)
        if k=="config" then
            return {
                keymaps = {},
                session = {
                    window = {}
                },
            }
        else
            return function (...)
                _ = ...
                utils.LogNotImplemented(k)
            end
        end
    end
})


-- Define commands
vim.api.nvim_create_user_command("CudaCompile", function(opts)
    profiler.nvcc.nvccCompile(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("CudaProfile", function(opts)
    profiler.nsys.nsysTracing(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("CudaCompute", function(opts)
    profiler.ncu.ncuTracing(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("CudaVisual", function(opts)
    profiler.nvvp.nvvpTracing(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("CudaProfileDir", function()
    local dir = "profiles/build_" .. os.date("%Y%m%d_%H%M%S")
    vim.fn.mkdir(dir, "p")
    profiler.nsys.nsysTracing("./" .. vim.fn.expand("%:r") .. " -o " .. dir .. "/profile")
end, { nargs = 0 })

vim.api.nvim_create_user_command("CudaProfileGit", function()
    local git_hash = vim.fn.system("git rev-parse --short HEAD"):gsub("\n", "")
    local dir = "profiles/build_" .. os.date("%Y%m%d_%H%M%S") .. "_" .. git_hash
    vim.fn.mkdir(dir, "p")
    profiler.nsys.nsysTracing("./" .. vim.fn.expand("%:r") .. " -o " .. dir .. "/profile")
    vim.fn.writefile({"Git: " .. git_hash}, dir .. "/meta.txt")
end, { nargs = 0 })

vim.keymap.set("n", "<leader>cc", ":CudaCompile -o %:r % -arch=sm_89<CR>", { silent = true })
vim.keymap.set("n", "<leader>cp", ":CudaProfileDir<CR>", { silent = true })
vim.keymap.set("n", "<leader>cu", ":CudaCompute ./%:r<CR>", { silent = true })
vim.keymap.set("n", "<leader>cv", ":CudaVisual ./%:r<CR>", { silent = true })
vim.keymap.set("n", "<leader>cg", ":CudaProfileGit<CR>", { silent = true })

utils.LogInfo("Modules loaded")

return M
