# scratchpad.nvim
> quickly edit and manage scratchpads

## WARNING: this is under construction (don't use it)

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
        require("scratchpad").setup({
            root_dir = "<put you scrathpad directory here>"
        })
    end,
}

```

## USAGE
* `:Sfind` - telescope find files of scratchpad dir
* `:Sgrep` - telescope find files of scratchpad dir
* `:Snew <filename>` - add a new file in the scratchpad dir

### TODO
* Save last selected file and allways open to it
* ?? git commit push on write
* Create a ui for scratchpad crud
* Allow custom keymaps
