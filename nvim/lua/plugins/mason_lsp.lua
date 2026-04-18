return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "html",
      "cssls",
      "lua_ls",
      "pyright",
      "clangd",
      "asm_lsp",
    },
  },
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = {
        ui = {
          icons = {
            package_installed = "𝓿",
            package_pending = "⏎",
            package_unistalled = "𝅃",
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
}
