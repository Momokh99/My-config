return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			offsets = {
				{ filetype = "NvimTree", text = "File Explorer", highlight = "Directory" },
			},
		},
	},
}
