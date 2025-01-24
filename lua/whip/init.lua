local plenary_found, Path = pcall(require, "plenary.path")
local telescope_found, ts_builtin = pcall(require, "telescope.builtin")
local _, ts_actions = pcall(require, "telescope.actions")
local _, ts_action_state = pcall(require, "telescope.actions.state")
local _, ts_action_set = pcall(require, "telescope.actions.set")

local M = {}
local state = {
    dir = nil,
    config_path = nil,
    config_autocreate = false,
    health_data = {
        is_setup = false,
        dir_err = nil,
        config_err = nil,
        plenary_found = plenary_found,
        telescope_found = telescope_found,
    },
    config_data = {
        current = nil,
    },
}

local log_info = function(fmt, ...)
    vim.notify(string.format(fmt, ...), vim.log.levels.INFO)
end

local log_error = function(fmt, ...)
    local err_msg = "ERROR: whip.nvim " .. string.format(fmt, ...)
    vim.notify(err_msg, vim.log.levels.ERROR)
    return err_msg
end

local log_error_dep_not_found = function(dep)
    return log_error("could not find %s", dep)
end

local is_empty = function(value)
    return value == "" or value == nil
end

local telescope_check_ok = function()
    if not telescope_found then
        log_error_dep_not_found("telescopenvim")
        return false
    end
    if state.dir == nil then
        log_error("error no whip dir")
        return false
    end
    return true
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
        state.health_data.config_err = log_error("cannot read config file: %s", state.config_path)
        return
    end
    local decode_ok, config_data = pcall(vim.fn.json_decode, config_json)
    if not decode_ok then
        state.health_data.config_err = log_error("cannot parse config json: %s", state.config_path)
        return
    end
    state.config_data = config_data
end

local config_save = function()
    if state.config_path == nil then
        return
    end

    local write_ok = pcall(function()
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
        state.health_data.dir_err = log_error("opts.dir does not exist: %s", path)
        return
    end
    if not dir_path:is_dir() then
        state.health_data.dir_err = log_error("opts.dir is not a directory: %s", path)
        return
    end
    state.dir = dir_path:expand()
    state.config_path = string.format("%s/.whip.json", state.dir)
end

M.find_file = function()
    if not telescope_check_ok() then
        return
    end
    ts_builtin.find_files({
        cwd = state.dir,
        prompt_title = "Find whip",
        attach_mappings = function(prompt_bufnr, _)
            ts_actions.select_default:replace(function()
                local selection = ts_action_state.get_selected_entry()
                if not selection and state.config_autocreate then
                    local newfile = ts_action_state.get_current_line()
                    current_set(newfile)
                    vim.cmd(string.format("edit! %s/%s", state.dir, newfile))
                    return true
                end
                local filename = selection[1]
                if is_empty(filename) then
                    return log_error("no file selecetd")
                end
                current_set(filename)
                ts_action_set.select(prompt_bufnr, "default")
            end)
            return true
        end,
    })
end

M.find_grep = function()
    if not telescope_check_ok() then
        return
    end
    ts_builtin.live_grep({
        cwd = state.dir,
        additional_args = { "--hidden" },
        attach_mappings = function(prompt_bufnr, _)
            ts_actions.select_default:replace(function()
                local selection = ts_action_state.get_selected_entry()
                if is_empty(selection.filename) then
                    return log_error("no selection made")
                end
                current_set(selection.filename)
                ts_action_set.select(prompt_bufnr, "default")
            end)
            return true
        end,
    })
end

M.drop = function()
    if not telescope_check_ok() then
        return
    end
    ts_builtin.find_files({
        cwd = state.dir,
        prompt_title = "Delete whip",
        attach_mappings = function(prompt_bufnr, _)
            ts_actions.select_default:replace(function()
                local selection = ts_action_state.get_selected_entry()
                ts_actions.close(prompt_bufnr)
                local filename = selection[1]
                if is_empty(filename) then
                    return log_info("aborted delete: no filed selecetd")
                end
                log_info("delete (%s)? .. press y for yes ", filename)
                local confirm_delete = vim.fn.getchar()
                local leter_y = 121
                if confirm_delete ~= leter_y then
                    return log_info("aborted delete")
                end
                local delete_ok = pcall(function()
                    Path:new(string.format("%s/%s", state.dir, selection[1])):rm()
                end)
                if not delete_ok then
                    return log_error("failed to delete (%s)", filename)
                end
                log_info("deleted (%s)", selection[1])
            end)
            return true
        end,
    })
end

M.make = function()
    local input = vim.fn.input({
        prompt = "create whip: ",
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

M._get_state = function()
    return state
end

M.setup = function(opts)
    opts = opts or {}
    if not telescope_found then
        return log_error_dep_not_found("telescope")
    end
    if not plenary_found then
        return log_error_dep_not_found("plenary")
    end
    if opts.autocreate then
        state.config_autocreate = opts.autocreate
    end
    if opts.dir then
        dir_set(opts.dir)
        if state.config_path ~= nil then
            config_load()
        end
    end

    vim.api.nvim_create_user_command("WhipOpen", M.open, {})
    vim.api.nvim_create_user_command("WhipMake", M.make, {})
    vim.api.nvim_create_user_command("WhipDrop", M.drop, {})
    vim.api.nvim_create_user_command("WhipFindFile", M.find_file, {})
    vim.api.nvim_create_user_command("WhipFindGrep", M.find_grep, {})
    state.health_data.is_setup = true
end

return M
