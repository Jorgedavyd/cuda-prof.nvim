---@class CudaProfTriggers
---@field mainSequence? CudaProfSequence Basically is the main CudaProfSequence object that has to be ran.
---@field new fun(self, mainSequence: CudaProfSequence):nil
---@field preSequence fun(self, opts: table):nil Prepared launching the mainSequence.
---@field postSequence fun(self, opts: table):nil Exits mainSequence.
---@field __call fun(self, opts: table):nil Basically runs the whole setup
local M = {}
M.__index = M

function M:new(mainSequence)
    setmetatable(M, self)
    self.mainSequence = mainSequence
    return self
end

function M:__call(opts)
    self:preSequence(opts)
    self.mainSequence(opts)
    self:postSequence(opts)
end

function M:preSequence()
end

function M:postSequence()
end

return M
