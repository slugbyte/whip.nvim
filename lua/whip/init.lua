local plenary_found, Path = pcall(require, "plenary.path")
local telescope_found, t_builtin = pcall(require, "telescope.builtin")
local _, t_actions = pcall(require, "telescope.actions")
local _, t_action_state = pcall(require, "telescope.actions.state")
local _, t_action_set = pcall(require, "telescope.actions.set")

local M = {}
local state = {
    dir = nil,
    config_path = nil,
    config_data = {
        current = nil,
    },
}

local log_error = function(fmt, ...)
    vim.notify("ERROR: whip.nvim " .. string.format(fmt, ...), vim.log.levels.ERROR)
end

local config_check_exists = function()
    if state.config_path == nil then
        return false
    end
    return Path:new(state.config_path):exists()
end

local config_load = function()
    if not config_check_exists() then
        return
    end
    if state.config_path == nil then
        return
    end
    local read_ok, config_json = pcall(function()
        return Path:new(state.config_path):read()
    end)
    if not read_ok then
        return
    end
    local decode_ok, config_data = pcall(vim.fn.json_decode, config_json)
    if not decode_ok then
        return log_error("cannot parse .whip.json")
    end
    state.config_data = config_data
end

local config_save = function()
    if state.config_path == nil then
        return
    end

    local write_ok, _ = pcall(function()
        Path:new(state.config_path):write(vim.fn.json_encode(state.config_data), "w")
    end)

    if not write_ok then
        return log_error("faled to update config: could not wite to %s", state.config_path)
    end
end

local current_whip_path = function()
    if state.config_data == nil or state.config_data.current == nil then
        return nil
    end
    return string.format("%s/%s", state.dir, state.config_data.current)
end

local current_whip_check_exists = function()
    local path = current_whip_path()
    if path == nil then
        return false
    end
    return Path:new(current_whip_path()):exists()
end

local current_set = function(current)
    state.config_data.current = current
    config_save()
end

local dir_set = function(path)
    local dir_path = Path:new(path)
    if not dir_path:exists() then
        log_error("opts.dir does not exist: %", path)
        return
    end
    if not dir_path:is_dir() then
        log_error("opts.dir is not a directory: %", path)
        return
    end
    state.dir = dir_path:expand()
    state.config_path = string.format("%s/.whip.json", state.dir)
end

M.find_file = function()
    if not telescope_found then
        return log_error("could not find telescope")
    end
    if state.dir == nil then
        return log_error("error no whip dir")
    end
    t_builtin.find_files({
        cwd = state.dir,
        prompt_title = "Find whip",
        attach_mappings = function(prompt_bufnr, _)
            t_actions.select_default:replace(function()
                -- save selected state
                local selection = t_action_state.get_selected_entry()
                if selection[1] ~= "" then
                    current_set(selection[1])
                end

                -- do original select
                t_action_set.select(prompt_bufnr, "default")
            end)
            return true
        end
    })
end

M.find_grep = function()
    if not telescope_found then
        return log_error("could not find telescope.nvim")
    end
    if state.dir == nil then
        return log_error("error no whip dir")
    end
    t_builtin.live_grep({
        cwd = state.dir,
        additional_args = { "--hidden" },
        attach_mappings = function(prompt_bufnr, _)
            t_actions.select_default:replace(function()
                -- save selected state
                local selection = t_action_state.get_selected_entry()
                if selection.filename ~= "" then
                    current_set(selection.filename)
                end
                -- do original select
                t_action_set.select(prompt_bufnr, "default")
            end)
            return true
        end
    })
end

M.make = function()
    local input = vim.fn.input({
        prompt = "create whip: "
    })
    current_set(input)
    vim.cmd(string.format("edit %s/%s", state.dir, input))
end

M.open = function()
    if not current_whip_check_exists() then
        return M.find_file()
    end
    vim.cmd(string.format("edit %s", current_whip_path()))
end

M.setup = function(opts)
    opts = opts or {}
    if not telescope_found then
        return log_error("could not find telescope.nvim")
    end
    if not plenary_found then
        return log_error("could not find plenary.nvim")
    end
    if opts.dir then
        dir_set(opts.dir)
        if state.config_path ~= nil then
            config_load()
        end
    end

    vim.api.nvim_create_user_command("WhipOpen", M.open, {})
    vim.api.nvim_create_user_command("WhipMake", M.make, {})
    vim.api.nvim_create_user_command("WhipFindFile", M.find_file, {})
    vim.api.nvim_create_user_command("WhipFindGrep", M.find_grep, {})
end

return M