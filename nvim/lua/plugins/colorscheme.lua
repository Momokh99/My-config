return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,	
    opts={
        flavor= "mocha",
        integration = {
            which_key = true,
            treesitter = true,
            blink_cmp = true,
            mason = true,
            telescope = { enabled = true },
        },    
    },

    config = function(_, opts)
        require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin-mocha")
	end,
}
