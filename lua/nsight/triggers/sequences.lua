local utils = require("nsight.utils")

---@class NsightSequence
---@field routines [fun(filepath: string): nil]
---@field new fun(self, routines: [fun(filepath: string): nil]):NsightSequence Instantiates a CudaProfSequence
---@field __call fun(self, filepath: string): nil Calls routines in sequence
---@field private call_set fun(self, filepaths: [string]): nil Calls a set as a sequence
local S = {}

S.__index = S

function S:new(routines)
    setmetatable(S, self)
    self.routines = routines
    return self
end

function S:__call (filepath)
    if not S.routines then
        utils.LogError("Routines not defined on nsight#run_sequence")
        return
    end
    for _, cuda_routine in ipairs(self.routines) do
        cuda_routine(filepath)
    end
end

function S:call_set(filepaths)
    for _, filepath in ipairs(filepaths) do
        self(filepath)
    end
end

return S
