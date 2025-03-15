local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("cuda-prof.nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    exports = {
        marks = require("telescope._extensions.marks"),
    },
})
-- shotout to harpoon
