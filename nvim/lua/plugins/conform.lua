return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			html = { "prettier" },
			json = { "prettier" },
			css = { "prettier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			python = { "black" },
			bash = { "shfmt" },
			sh = { "shfmt" },
		},
		format_on_save = {
			timeout_ms = 2000,
			lsp_fallback = true,
		},
	},
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Format File",
		},
	},
}
