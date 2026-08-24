return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			theme = "catppuccin-mocha",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = {
				"mode",
				{
					function()
						local bufs = vim.fn.getbufinfo({ buflisted = true })
						local current = vim.fn.bufnr()
						for i, buf in ipairs(bufs) do
							if buf.bufnr == current then
								return string.format("[%d/%d]", i, #bufs)
							end
						end
						return ""
					end,
				},
			},
			lualine_b = { "branch" },
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { "diagnostics", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
