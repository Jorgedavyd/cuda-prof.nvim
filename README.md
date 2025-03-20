<div align="center">

# nsight.nvim
###### NVIDIA Nsight Integrated tools for Neovim.
<img height="480" src="/assets/nsight-logo.png" />

[![Neovim](https://img.shields.io/badge/Neovim-blue.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
[![CUDA](https://img.shields.io/badge/CUDA-green.svg?style=for-the-badge&logo=nvidia)](https://developer.nvidia.com/cuda-toolkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

## Overview

`nsight.nvim` is a Neovim plugin that provides seamless integration with NVIDIA Nsight profiling tools. It allows you to manage CUDA profiling sessions, run various NVIDIA tools, and analyze profiling results without leaving your editor.

## Requirements

- [Neovim](https://neovim.io) (v0.9.0 or higher)
- NVIDIA CUDA Toolkit:
  - `nvcc`: NVIDIA CUDA Compiler
  - `nvvp`: NVIDIA Visual Profiler
  - `ncu`: NVIDIA Nsight Compute
  - `nsys`: NVIDIA Nsight Systems

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "Jorgedavyd/nsight.nvim",
    config = function()
        require("nsight").setup({
            -- Your configuration here
        })
    end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "Jorgedavyd/nsight.nvim",
    config = function()
        require("nsight").setup({
            -- Your configuration here
        })
    end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Jorgedavyd/nsight.nvim'

" After installation, in your init.lua:
" lua require('nsight').setup({})
```

### Using [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('Jorgedavyd/nsight.nvim')

" After installation, in your init.lua:
" lua require('nsight').setup({})
```

## Configuration

### Default Configuration

```lua
require("nsight").setup({
    session = {
        window = {
            title = "Nsight Session",
            title_pos = "left",
            width_in_columns = 12,
            height_in_lines = 8,
            style = "minimal",
            border = "single"
        },
        keymaps = function(bufnr)
            -- Define your keymaps here
        end,
        resolve_triggers = {}
    },
    extensions = {
        telescope = {},
        sqlite = {},
        cli = {}
    }
})
```

## Functionalities

### Main Features

- **Session Management**: Create and manage CUDA profiling sessions
- **File Integration**: Add CUDA source files to your profiling session
- **Tool Integration**: Run NVIDIA profiling tools directly from Neovim
- **Report Analysis**: View and analyze profiling reports
- **Project Management**: Organize profiling experiments per project

### Commands

| Command | Description |
|---------|-------------|
| `NsightActivate` | Activate the profiling session |
| `NsightDeactivate` | Deactivate the profiling session |
| `NsightToggle` | Toggle the profiling session |
| `Nvcc` | Run NVIDIA CUDA Compiler |
| `Ncu` | Run NVIDIA Nsight Compute |
| `Nvvp` | Run NVIDIA Visual Profiler |
| `Nsys` | Run NVIDIA Nsight Systems |
| `NsysUi` | Open NVIDIA Nsight Systems UI |
| `NcuUi` | Open NVIDIA Nsight Compute UI |

### API Functions

| Function | Description |
|----------|-------------|
| `toggle_include()` | Include the current buffer's filepath in the session |
| `toggle_view()` | Open the interactive session window |

### Telescope Integration

The plugin integrates with Telescope for enhanced file selection and report browsing:

```lua
-- Add to your telescope configuration
telescope.load_extension('nsight')

-- Usage
:Telescope nsight file_add_cuda    -- Find and add CUDA files to session
:Telescope nsight nsys_open_report -- Open Nsight Systems reports
:Telescope nsight ncu_open_report  -- Open Nsight Compute reports
```

## Project Structure

`nsight.nvim` creates a `.nsight.nvim` directory in your project root to store profiling experiments and configurations. Experiments are organized based on the files being profiled.

### Experiment Structure

```
.nsight.nvim/
├── .config                    # Session configuration
└── experiments/
    └── file1_file2/           # Experiment for specific files
        ├── report1/           # Profiling report
        ├── report2/
        └── .history           # Experiment history
```

## Examples

### Basic Usage

```lua
-- In your init.lua
require("nsight").setup()

-- In Neovim
:NsightToggle           -- Open the profiler window
-- Add CUDA files to the session
:NsightDeactivate       -- Save the session
:Nvcc -o output main.cu       -- Compile a CUDA file
:Nsys profile ./output        -- Profile the compiled binary
:Telescope nsight nsys_open_report -- View the report
```

### Custom Keymaps

```lua
require("nsight").setup({
    session = {
        keymaps = function(bufnr)
            -- Define keymaps for the profiler buffer
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>',
                "<cmd>lua require('nsight').toggle_include()<CR>",
                { noremap = true, silent = true })

            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q',
                "<cmd>lua require('nsight.ui').close_menu()<CR>",
                { noremap = true, silent = true })
        end
    }
})
```

## Contributing

Contributions are welcome! Check out the [todo.md](todo.md) file for planned features and improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
