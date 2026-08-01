return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git/" },
					path_display = { "truncate" },
				},
			})

			-- Enable FZF native sorter if installed
			pcall(telescope.load_extension, "fzf")

			-- Keymaps
			local keymap = vim.keymap.set
			keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			keymap("n", "<leader>fg", builtin.live_grep, { desc = "Find text (Grep)" })
			keymap("n", "<leader>fb", builtin.buffers, { desc = "Find open buffers" })
			keymap("n", "<leader>fh", builtin.help_tags, { desc = "Search help tags" })
			keymap("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent files" })
		end,
	},
}
