return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Custom ASCII Header
    dashboard.section.header.val = {
      " ███╗   ██╗██╗   ██╗██╗███╗   ███╗ ",
      " ████╗  ██║██║   ██║██║████╗ ████║ ",
      " ██╔██╗ ██║██║   ██║██║██╔████╔██║ ",
      " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    }

    -- Dashboard Action Buttons
    dashboard.section.buttons.val = {
      dashboard.button("f", "󰍉  Find File", "<cmd>Telescope find_files<cr>"),
      dashboard.button("r", "󰋚  Recent Files", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("g", "󰈞  Live Grep", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("e", "󰙅  Explorer (netrw)", "<cmd>Explore<cr>"),
      dashboard.button("b", "󰓩  Open Buffers", "<cmd>Telescope buffers<cr>"),
      dashboard.button("u", "󰊤  Update Plugins", "<cmd>Lazy sync<cr>"),
      dashboard.button("q", "󰅚  Quit Neovim", "<cmd>qa<cr>"),
    }

    -- Recent Files section
    dashboard.section.mru_cwd.val = {
      { header = { "Recent Files" }, auto_close = true },
    }
    dashboard.section.mru_cwd.opts.hl = "AlphaHeader"

    -- Footer stats (shows loaded plugins and timing)
    local function footer()
      local ok, stats = pcall(require, "lazy")
      if ok then
        stats = stats.stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        return "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
      end
      return "⚡ Neovim"
    end

    dashboard.section.footer.val = footer()

    -- Apply Catppuccin highlights
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    alpha.setup(dashboard.opts)

    -- Hide statusline and tabline on Alpha startup screen
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.opt.laststatus = 0
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].filetype = "alpha"
        vim.bo[buf].bufhidden = "wipe"
      end,
    })

    -- Restore statusline when leaving Alpha
    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "alpha",
      callback = function()
        vim.opt.laststatus = 3
      end,
    })
  end,
}
