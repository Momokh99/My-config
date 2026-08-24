return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		view = {
			width = 30,
		},
		renderer = {
			indent_markers = { enable = true },
			icons = {
				glyphs = {
					folder = { arrow_open = "", arrow_closed = "" },
				},
			},
		},
		filters = {
			dotfiles = false,
		},
		diagnostics = {
			enable = true,
			icons = { hint = "", info = "", warning = "", error = "" },
		},
		git = {
			enable = true,
			icons = {
				unstaged = "",
				staged = "",
				unmerged = "",
				renamed = "",
				untracked = "",
				deleted = "",
				ignored = "",
			},
		},
		actions = {
			open_file = {
				window_picker = { enabled = false },
				quit_on_open = true,
			},
		},
		keymaps = {
			custom_only = false,
			list = {
				{ key = "l", action = "edit", mode = "n" },
				{ key = "h", action = "close_node", mode = "n" },
				{ key = "a", action = "create", mode = "n" },
				{ key = "d", action = "remove", mode = "n" },
				{ key = "r", action = "rename", mode = "n" },
				{ key = ".", action = "toggle_dotfiles", mode = "n" },
			},
		},
	},
	keys = {
		{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Explorer" },
	},
}
