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
    return function()
        telescope_builtin.find_files({
            hidden = true,
            cwd = state.root_dir,
        })
    end
end

M.setup = function(config)
    if config == nil then
        config = {}
    end

    if config.root_dir then
        state.root_dir = config.root_dir
    end

    vim.api.nvim_create_user_command("Scratchpad", telescope_find_files, {})
    log_info("biew biew biew")
end

return M
