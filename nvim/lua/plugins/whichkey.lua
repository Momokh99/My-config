return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
        preset="modern",
        win={
            border = "rounded"},
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
