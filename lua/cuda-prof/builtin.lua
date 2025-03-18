return setmetatable({},{
    __index = function (_, k)
        return require("cuda-prof.triggers.builtin")[k]
    end
})
