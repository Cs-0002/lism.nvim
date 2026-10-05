# lism.nvim
`lism.nvim` is a Neovim plugin that highlights the elements of Common Lisp forms.  
When the cursor is on `(`, every element inside that list gets its own background color,  
so you can see at a glance how many arguments a form has and where each one ends.  


https://github.com/user-attachments/assets/68a36705-b7c7-4c4d-b421-e0d9482dbbf8


## Features
- Highlights each element of the list under the cursor when the cursor is on `(`
- Colors are spread evenly around the hue circle according to the number of elements
- Comments inside the list are not highlighted
- Nothing is highlighted if the list is not closed, which helps spot a missing `)`

## Requirements
- Neovim 0.9+
- Tree-sitter parser for Common Lisp 
## Installation
With [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "cs-0002/lism.nvim",
  ft = "lisp",
  opts = {
    -- saturation = 50, -- saturation of the highlight colors (0-100)
    -- lightness = 20,  -- lightness of the highlight colors (0-100)
  },
}
```

