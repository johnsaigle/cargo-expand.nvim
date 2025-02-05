local M = {}

-- Default configuration
M.config = {}

-- Setup function that users will call
function M.setup(opts)
	-- Merge user config with defaults
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	-- Create the user command
	vim.api.nvim_create_user_command('CargoExpand', function()
		require('cargo-expand.expand').expand()
	end, {})
end

return M
