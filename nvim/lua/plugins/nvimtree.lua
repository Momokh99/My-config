return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		disable_netrw = true,
		hijack_netrw = true,
		view = {
			width = 30,
		},
		renderer = {
			indent_markers = { enable = true },
			icons = {
				glyphs = {
					folder = {
						arrow_open = "",
						arrow_closed = "",
					},
					git = {
						unstaged = "✗",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						untracked = "★",
						deleted = " ",
						ignored = "◌",
					},
				},
			},
		},
		filters = {
			dotfiles = false,
		},
		diagnostics = {
			enable = true,
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		git = {
			enable = true,
		},
		actions = {
			open_file = {
				window_picker = {
					enable = false,
				},
				quit_on_open = true,
			},
		},
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return {
					desc = "nvim-tree: " .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true,
				}
			end

			api.map.on_attach.default(bufnr)

			vim.keymap.set("n", "l", function() api.node.open.edit() end, opts("Open"))
			vim.keymap.set("n", "h", function() api.node.navigate.parent_close() end, opts("Close Directory"))
			vim.keymap.set("n", ".", function() api.tree.toggle_dotfiles() end, opts("Toggle Dotfiles"))
			pcall(vim.keymap.del, "n", "<C-e>", { buffer = bufnr })
		end,
	},
	keys = {
		{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Explorer" },
	},
	cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeFindFile" },
}
