---@class CudaProfProjectManager Basically manages all IO operations and setting up experiments.
---@field init fun(opts: table): nil
---@field getExperiments fun():[CudaProfExperiment] Gets a list of CudaProfExperiment objects from the CudaProfDirectory.
---@field getProjectPath fun():string Gets the project name for the current filepath. (Overwritten by user)
---@field setupProject fun(opts: table): nil Sets up the projects.
---@field getConfigFile fun():string Gets the config file path cuda-prof.json
---@field getHistoryFile fun():string Gets the history file path cuda-prof_history
---@field gitOpts fun():nil Implements the git operations on project path for .gitignore and other.
---@field namingConvention fun(filepath: string):string Implements the file naming routine for every experiment on each file.
---@field autoNumeration fun():string Implements the autonumeration routine for sequential experiments.
---@field destructor fun():string Implements the destruction routine for the project manager.
local M = {}

---@private Can just be created by CudaProfProjectManager object.
---@class CudaProfExperiment
---@field basename? string
---@field getReport fun():string
---@field getDatabase fun():string
---@field getDiagnosticSummary fun():string
---@field getAnalysisSummary fun():string
local experiment = {}

---@private Inner object for creation manager routines.
---@class CudaProfDirectory
---@field init fun(string): nil Instantiates and checks if there's a directory for the current project based on the creation routine.
---@field creationRoutine fun(string):string Creation routine for the Cuda Profiler Project.
---@field createDirectory fun(string):nil Creates the CudaProf folder path for experiments and configurations.
---@field directory string
---@field __call fun():string
---@field destructor fun():nil
local directory = {}

---@private Inner object for creation manager routines.
---@class CudaProfFile
---@field init fun(string): nil
---@field filepath? string
---@field __call fun():string
---@field destructor fun():nil
local file = {}

return M
