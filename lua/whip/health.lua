local whip = require("whip")

local M = {}

M.check = function()
    local whip_state = whip._get_state()

    if not whip_state.health_data.is_setup then
        vim.health.report_error("whip.nvim setup() was never run")
        return
    end

    local is_ok = true
    if not whip_state.health_data.plenary_found then
        vim.health.report_error("could not find plenary.nvim")
        is_ok = false
    end

    if not whip_state.health_data.telescope_found then
        vim.health.report_error("could not find telescope.nvim")
        is_ok = false
    end

    if whip_state.health_data.dir_err ~= nil then
        vim.health.report_error(whip_state.health_data.dir_err)
        is_ok = false
    end

    if whip_state.health_data.config_err ~= nil then
        vim.health.report_error(whip_state.health_data.config_err)
        is_ok = false
    end
    if is_ok then
        vim.health.ok("whip.nvim setup is ok!")
    end
end

return M
