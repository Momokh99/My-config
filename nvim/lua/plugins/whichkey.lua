return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
        preset="modern",
        win={
            border = "rounded"},
        spec = {
            { "<leader>b", group = "Buffers" },
            { "<leader>e", group = "Explorer" },
            { "<leader>f", group = "Fzf Telescope" },
        },
        },
	keys = {
		{
			"<leader>",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Show local keymaps",
		},
	},
}
