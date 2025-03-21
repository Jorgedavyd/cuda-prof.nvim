local manager = require("nsight.manager")
local utils = require("nsight.utils")

---@class NsightTriggers
---@field mainSequence? NsightSequence Basically is the main CudaProfSequence object that has to be ran.
---@field mng NsightProjectManager IO operator.
---@field new fun(self, mainSequence: NsightSequence):nil
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

return M
