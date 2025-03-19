local manager = require("cuda-prof.manager")
local utils = require("cuda-prof.utils")

---@class CudaProfTriggers
---@field mainSequence? CudaProfSequence Basically is the main CudaProfSequence object that has to be ran.
---@field mng CudaProfProjectManager IO operator.
---@field new fun(self, mainSequence: CudaProfSequence):nil
---@field preSequence fun(self, opts: table):nil Prepared launching the mainSequence.
---@field postSequence fun(self, opts: table):nil
---@field __call fun(self, opts: table):nil
---@field setup fun():nil
local M = {}
M.__index = M

function M:new(mainSequence)
    setmetatable(M, self)
    self.mainSequence = mainSequence
    self.mng = manager:new()
    return self
end

function M:__call(opts)
    self:preSequence(opts)
    self.mainSequence(opts)
end

function M:preSequence(filepaths)
    local filtered = self.mng:check_filepaths(filepaths)
    if filtered ~= nil then
        self.mng:sequence_trigger(filtered)
        return
    end
    utils.LogError("Couldn't find a valid CUDA file")
end

function M.setup()
end

return M
