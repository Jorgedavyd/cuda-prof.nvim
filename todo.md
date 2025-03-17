# TODO

# SCHEMA

session -> (
    Got to define the specifics.
    My idea is that the Cuda Prof Sessions should be made for integrated profiling sessions.
    Example:
    -> Add files to Cuda Prof Session (maybe in a harpoon way, maybe toggling, logging that to user).
    -> Create the environment for the reports (maybe a function that creates a folder, and routines for naming conventions).
    -> Routines for construction: folder per project on .git trigger maybe?
    -> Folders (naming conventions as well): .git trigger maybe?
    -> File naming conventions: fun(filepath: string): string
    -> Automatic naming and numeration: fun(filepath: string, naming: function): string ## This would be utils
    -> Trigger a given routine on Cuda Prof files for CUDA for every Cuda Prof Files -> (
    Example:
        ('n', '<leader>cu', function () ... -- routine for nvcc; end)
        keymap('n', '<leader>cc', function () ... -- routine for ncu; end)
        keymap('n', '<leader>cs', function () ... -- routine for nsys; end)
        keymap('n', '<leader>ct', function () ... -- routine for all in one; end)
    )
    -> BufferLeave checking for filepath correctness (or at trigger) -> just a warning if a path is not ok
);
