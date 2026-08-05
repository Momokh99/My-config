return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Catppuccin palette for custom highlights
    local ok, palette = pcall(require, "catppuccin.palettes")
    local colors = ok and palette.get_palette("mocha") or nil

    -- Custom ASCII Header
    dashboard.section.header.val = {
      " ███╗   ██╗██╗   ██╗██╗███╗   ███╗ ",
      " ████╗  ██║██║   ██║██║████╗ ████║ ",
      " ██╔██╗ ██║██║   ██║██║██╔████╔██║ ",
      " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    }

    -- Header color (single, no rainbow)
    if colors then vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.blue }) end
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- Button text color
    if colors then vim.api.nvim_set_hl(0, "AlphaButtonsText", { fg = colors.subtext1 }) end

    -- Colored button builder: icon gets its own color, text gets AlphaButtonsText
    local function button(sc, icon, txt, keybind, icon_hl)
      local b = dashboard.button(sc, icon .. "  " .. txt, keybind)
      b.opts.hl = {
        { icon_hl, 0, #icon },
        { "AlphaButtonsText", #icon + 2, -1 },
      }
      return b
    end

    dashboard.section.buttons.val = {
      button("f", "󰍉", "Find File", "<cmd>Telescope find_files<cr>", "Function"),
      button("r", "󰋚", "Recent Files", "<cmd>Telescope oldfiles<cr>", "String"),
      button("g", "󰈞", "Live Grep", "<cmd>Telescope live_grep<cr>", "Keyword"),
      button("e", "󰙅", "Explorer (netrw)", "<cmd>Explore<cr>", "Type"),
      button("b", "󰓩", "Open Buffers", "<cmd>Telescope buffers<cr>", "Number"),
      button("u", "󰊤", "Update Plugins", "<cmd>Lazy sync<cr>", "Operator"),
      button("q", "󰅚", "Quit Neovim", "<cmd>qa<cr>", "DiagnosticError"),
    }

    -- Footer stats (shows loaded plugins and timing)
    local function footer()
      local fok, stats = pcall(require, "lazy")
      if fok then
        stats = stats.stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        return "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
      end
      return "⚡ Neovim"
    end

    dashboard.section.footer.val = footer()
    if colors then vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.overlay1 }) end
    dashboard.section.footer.opts.hl = "AlphaFooter"

    alpha.setup(dashboard.opts)

    -- Hide statusline and tabline on Alpha startup screen
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].filetype = "alpha"
        vim.bo[buf].bufhidden = "wipe"
      end,
    })

    -- Show/hide statusline based on current buffer filetype
    vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.opt.laststatus = vim.bo[buf].filetype == "alpha" and 0 or 3
      end,
    })
  end,
}
