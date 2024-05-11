# scratchpad.nvim
> quickly edit and manage scratchpads

## SETUP
```lua
-- lazy nvim setup
return {
    "slugbyte/scratchpad.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local scratchpad = require("scratchpad")
        scratchpad.setup({
            dir = "~/your/scratchpad/dir/goes-here"
        })
        vim.keymap.set("", "<leader>so", scratchpad.open, { desc = "[S]cratchpad [O]pen" })
        vim.keymap.set("", "<leader>sm", scratchpad.make, { desc = "[S]cratchpad [M]ake" })
        vim.keymap.set("", "<leader>sf", scratchpad.find_file, { desc = "[S]cratchpad [F]ile Search" })
        vim.keymap.set("", "<leader>sg", scratchpad.find_grep, { desc = "[S]cratchpad [G]rep Search" })
    end,
}
```

## USAGE
scratchpad.nvim allows you to quickly edit files in the scratchpad `dir`
configured with `setup()`. The main benefit it provides over vanilla telescope.nvim is that
it remembers the last scratchpad you edited.

## lua api
* `scratchpad.open()` open last selected scratchpad file, if no file is selected
it will trigger `scratchpad.find_file()`
* `scratchpad.make()` prompt to create a new scratchpad file
* `scratchpad.find_file()` telescope scratchpad files
* `scratchpad.find_grep()` telescope grep scratchpad files

## commands
* `:ScratchpadOpen` calls `scratchpad.open()`
* `:ScratchpadMake` calls `scratchpad.make()`
* `:ScratchpadFindFile` calls `scratchpad.find_file()`
* `:ScratchpadFindGrep` calls `scratchpad.find_grep()`

I use different scratchpads for different projects, that I tend to reference a lot while I'm working.
I find it super nice to be able to quickly pop open then scratchpad for what
ever I'm working on without having to find_files every time.

## NOTE
scratchpad.nvim creates a `.scratchpad.json` in your scratchpad `dir` to keep track of
your last selected file.

## TODO:
* health check
