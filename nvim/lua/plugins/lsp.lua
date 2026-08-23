return {
	"williamboman/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"html",
			"jsonls",
			"bashls",
			"cssls",
			"lua_ls",
			"pyright",
			"ts_ls",
		},
	},
	dependencies = {
		{
			"williamboman/mason.nvim",
			opts = {
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			},
		},
		{
			"neovim/nvim-lspconfig",
			config = function()
				local keymap = vim.keymap.set

				vim.api.nvim_create_autocmd("LspAttach", {
					callback = function(args)
						local opts = { buffer = args.buf, silent = true }
						keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
						keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
						keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
						keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
						keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
					end,
				})
			end,
		},
	},
}
