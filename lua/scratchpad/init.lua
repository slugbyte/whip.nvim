local telescope_status, _ = pcall(require, "telescope")

local M = {}
local state = {
    root_dir = nil,
}

local _, t_builtin = pcall(require, "telescope.builtin")
local _, t_pickers = pcall(require, "telescope.pickers")
local _, t_finders = pcall(require, "telescope.finders")
local _, t_actions = pcall(require, "telescope.actions")
local _, t_action_state = pcall(require, "telescope.actions.state")
local _, t_action_set = pcall(require, "telescope.actions.set")

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
    t_builtin.find_files({
        hidden = true,
        cwd = state.root_dir,
        attach_mappings = function(prompt_bufnr, _)
            t_actions.select_default:replace(function()
                -- save selected state
                local selection = t_action_state.get_selected_entry()
                vim.defer_fn(function()
                    log_error("selected: %s", selection[1])
                end, 0)
                -- do original select
                t_action_set.select(prompt_bufnr, "default")
            end)
            return true
        end
    })
end

local telescope_live_grep = function()
    if not telescope_status then
        return log_error("telescope not found")
    end
    if state.root_dir == nil then
        return log_error("error no scratchpad root_dir")
    end
    t_builtin.live_grep({
        cwd = state.root_dir,
        additional_args = { "--hidden" },

    })
end

M.setup = function(config)
    if config == nil then
        config = {}
    end

    if not telescope_status then
        return log_error("scratchpad.nvim error: telescope not found")
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

    -- vim.keymap.set("", "<leader><leader>w", , { desc = "test" })
    -- test_picker({})
    vim.keymap.set("", "<leader>w", telescope_find_files, { desc = "Scratchpad File Search" })
    vim.keymap.set("", "<leader>W", telescope_find_files, { desc = "Scratchpad Grep Search" })
end

return M
