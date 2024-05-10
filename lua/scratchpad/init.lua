local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")

local M = {}
local state = {
    root_dir = nil,
}

local log_error = function(fmt, ...)
    vim.notify(string.format(fmt, ...), vim.log.levels.ERROR)
end

local log_info = function(fmt, ...)
    vim.notify(string.format(fmt, ...), vim.log.levels.INFO)
end

local telescope_find_files = function()
    if not telescope_status then
        return log_error("telescope not found")
    end
    if state.root_dir == nil then
        return log_error("error no scratchpad root_dir")
    end
    telescope_builtin.find_files({
        hidden = true,
        cwd = state.root_dir,
    })
end

local telescope_live_grep = function()
    if not telescope_status then
        return log_error("telescope not found")
    end
    if state.root_dir == nil then
        return log_error("error no scratchpad root_dir")
    end
    telescope_builtin.live_grep({
        cwd = state.root_dir,
        additional_args = { "--hidden" },
    })
end

M.setup = function(config)
    if config == nil then
        config = {}
    end

    if config.root_dir then
        state.root_dir = config.root_dir
    end

    vim.api.nvim_create_user_command("Sfind", telescope_find_files, {})
    vim.api.nvim_create_user_command("Sgrep", telescope_live_grep, {})
    vim.api.nvim_create_user_command("Snew",
        function(opt)
            -- TODO: make this a prompt instead
            local name = opt.args
            vim.cmd(string.format(":e %s/%s", state.root_dir, name))
        end,
        { nargs = 1 }
    )

    vim.keymap.set("", "<leader>w", telescope_find_files, { desc = "Scratchpad File Search" })
    vim.keymap.set("", "<leader>W", telescope_find_files, { desc = "Scratchpad Grep Search" })
end

return M
