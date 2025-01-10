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

Place your cursor on any Rust identifier and run `:CargoExpand`. This will:
- Run `cargo expand` on your project
- Switch to the expanded code in the current buffer
- Add all occurrences to the quickfix list

## Requirements

- Neovim >= 0.8.0
- `cargo-expand` tool (`cargo install cargo-expand`)
