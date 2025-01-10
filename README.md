# cargo-expand.nvim

A Neovim plugin for viewing expanded Rust macros using `cargo expand`.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'johnsaigle/cargo-expand.nvim',
    config = function()
        require('cargo-expand').setup(}
    end
}
```

## Usage

- Open neovim in the directory containing the appropriate `Cargo.toml` file.
- Place your cursor on any Rust identifier and run `:CargoExpand`. 

This will:
- Run `cargo expand` on your project
- Switch to the expanded code in the current buffer
- Add all occurrences to the quickfix list
- Cache the expanded file

## Requirements

- Neovim >= 0.8.0
- `cargo-expand` tool (`cargo install cargo-expand`)

## TODO

The script could be improved by finding the 'closest' `Cargo.toml` file to the file in the current buffer.
This would make it so that neovim doesn't need to be launched from the directory that has the right Cargo.toml file.
- first check cwd
- if Cargo.toml is virtual manfiest, look at options in child directories
- otherwise, look at parent directory
