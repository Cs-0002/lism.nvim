# lism.nvim
`lism.nvim` highlight Common Lisp code.


https://github.com/user-attachments/assets/68a36705-b7c7-4c4d-b421-e0d9482dbbf8


## Features
highlight elements when cursor on "("

## Installation
Use your package manager. For example, using lazy:
```
{
  "cs-0002/lism.nvim",
  opts = {
    -- saturation = 50,
    -- lightness = 20
  },
}
```

## Requirements
- Neovim 0.9+
- Common Lisp treesitter parser (`:TSInstall commonlisp`)
