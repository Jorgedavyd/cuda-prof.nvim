return setmetatable({},{
    __index = function (_, k)
        return require("cuda-prof.triggers.builtin")[k] or require("cuda-prof.triggers.routines.builtin")[k]
    end
})
