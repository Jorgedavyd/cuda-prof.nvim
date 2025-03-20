return setmetatable({},{
    __index = function (_, k)
        return require("nsight.triggers.builtin")[k] or require("nsight.triggers.routines.builtin")[k]
    end
})
