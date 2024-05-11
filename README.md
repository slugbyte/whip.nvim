# WHIP.NVIM
> biew biew biew, a super quick scratchpad manager

![whip logo](./asset/whip.png)

## INSTALL
* use your favorite package manager to install `slugbyte/whip.nvim` and dependencies
   * [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) 
   * [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## SETUP
```lua
-- example lazy nvim config
return {
    "slugbyte/whip.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local whip = require("whip")
        whip.setup({
            -- its probs a good idea to have a dir dedicated to your scratchpads
            dir = "~/your/whip/dir/goes-here"
        })
        vim.keymap.set("", "<leader>wo", whip.open, { desc = "[W]hip [O]pen" })
        vim.keymap.set("", "<leader>wm", whip.make, { desc = "[W]hip [M]ake" })
        vim.keymap.set("", "<leader>wf", whip.find_file, { desc = "[W]hip [F]ile Search" })
        vim.keymap.set("", "<leader>wg", whip.find_grep, { desc = "[W]hip [G]rep Search" })
    end,
}
```

## USAGE
whip.nvim allows you to quickly edit files in the whip `dir` configured with `setup()`. 
The main benefit it provides over vanilla telescope.nvim is that it remembers the last whip you edited.

I use different scratchpads for different projects, and while I'm working on a
particular project I tend to reference it's scratchpad over and over. I made this thing because I find 
it super nice to be able to quickly pop open the last scratchpad I used.

## LUA API
* `whip.open()` open last selected whip file, if no file is selected
it will trigger `whip.find_file()`
* `whip.make()` prompt to create a new whip file
* `whip.find_file()` telescope whip files
* `whip.find_grep()` telescope grep whip files

## COMMANDS
* `:WhipOpen` calls `whip.open()`
* `:WhipMake` calls `whip.make()`
* `:WhipFindFile` calls `whip.find_file()`
* `:WhipFindGrep` calls `whip.find_grep()`


## NOTE
whip.nvim creates a `.whip.json` in your whip `dir` to keep track of
your last selected file.

## SELF-PROMO
If you like this project star the GitHub repository :)

## ACKNOWLEDGMENT
> I referenced the source code in these projcects when trying to figure out how to use the nvim apis
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Find, Filter, Preview, Pick. All lua, all the time.
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - All the lua functions you don't want to write twice.
