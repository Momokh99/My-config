local lspconfig = require("lspconfig")

local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

local common_config = {
  capabilities = get_capabilities(),
}

--python lang
lspconfig.pyright.setup(vim.tbl_deep_extend("force", common_config, {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "OnlyFilesOnly",
        useLibaryCodeForTypes = true,
        typeCheckingMode = "basic",
      },
    },
  },
}))

--go lang
lspconfig.gopls.setup(vim.tbl_deep_extend("force", common_config, {
  settings = {
    gopls = {
      ["build.buildFlags"] = {},
      ["hints.inlayHint"] = {
        parameterNames = "all",
      },
    },
  },
}))

--rust lang
lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", common_config, {
  settings = {
    ["rust_analyzer"] = {
      diagnostics = {
        enable = true,
        diabled = { "unresolved-proc-macro" },
      },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = false },
    },
  },
}))

--lua lang
lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common_config, {
  settings = {
    lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        enable = true,
        unusedLocal = false,
      },
      workspace = {
        libary = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
}))

--c lang
lspconfig.clangd.setup(vim.tbl_deep_extend("force", common_config, {
  cmd = {
    "clangd",
    "--completion-style=detaled",
    "--header-insertion=never",
    "clang-tidy",
  },

  filetypes = { "c", "cpp", "objc", "objcpp" },
}))
