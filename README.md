# Do-At-Each.nvim

A Neovim plugin that allows you to execute a macro at each occurrence of a search pattern or at each line in a selection.

## Features

- Execute a macro at each occurrence of the last search pattern
- Execute a macro at each line in visual block selection

## Requirements

- Neovim >= 0.5.0

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
    'z0rzi/do-at-each.nvim',
    config = function()
        require('do-at-each').setup({
            -- Optional: customize the default mappings
            mappings = {
                do_at_each_normal_mode = 'M',  -- Default mapping in normal mode
                do_at_each_visual_mode = 'M',  -- Default mapping in visual mode
            }
        })
    end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'z0rzi/do-at-each.nvim',
    config = function()
        require('do-at-each').setup()
    end
}
```

## Usage

### Search Pattern Mode

1. Search for a pattern using `/` or `?`
2. Press `M` (or your configured mapping) in normal mode
3. Enter the macro you want to execute
4. The macro will be executed at each match of the search pattern

**Tip**: Use the visual mode (line or normal) to only apply the macro to the matches within the selected region.

### Visual Block Mode

1. Select lines in visual mode (`v`, `V`, or `<C-v>`)
2. Press `M` (or your configured mapping)
3. Enter the macro you want to execute
4. The macro will be executed at each line in the selection, at the column corresponding to the left edge of the selection

## Configuration

You can customize the mappings when setting up the plugin:

```lua
require('do-at-each').setup({
    mappings = {
        do_at_each_normal_mode = '<Leader>M',  -- Change normal mode mapping
        do_at_each_visual_mode = '<Leader>M',  -- Change visual mode mapping
    }
})
```

## Examples

1. Append a semicolon to each line ending with a specific pattern:
   - Search for the pattern: `/pattern$`
   - Press `M`
   - Enter macro: `A;`

2. Add quotes around words in a visual block:
   - Select words with `<C-v>`
   - Press `M`
   - Enter macro: `i"<>ea"`

## License

See [LICENSE](LICENSE) file.
