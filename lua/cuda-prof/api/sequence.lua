local utils = require("cuda-prof.utils")

---@class CudaProfSequence
---@field routines [CudaProfRoutine]
---@field __call fun(self, filepath: CudaProfFile): nil
---@field call_set fun(self, filepaths: [CudaProfFile]): nil
local S = {}

S.__index = S

---Instantiates a CudaProfSequence
---@param routines [CudaProfSequence]
function S.new(routines)
    local self = {}
    setmetatable(self, S)
    self.routines = routines
end

---Calls routines in sequence
---@private
---@param filepath CudaProfFile
function S:__call (filepath)
    if not S.routines then
        utils.LogError("Routines not defined on cuda-prof#run_sequence")
        return
    end
    for _, cuda_routine in ipairs(self.routines) do
        cuda_routine(filepath)
    end
end


---Calls routines in sequence
---@private
---@param filepaths [CudaProfFile]
function S:call_set(filepaths)
    for _, filepath in ipairs(filepaths) do
        self(filepath)
    end
end

return S
