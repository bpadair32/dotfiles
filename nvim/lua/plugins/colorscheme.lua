-- Dynamic colorscheme based on system theme.
-- theme-switch writes ~/.cache/nvim/current-theme when switching themes.

local function read_system_colorscheme()
  local theme_file = vim.fn.expand("~/.cache/nvim/current-theme")
  if vim.fn.filereadable(theme_file) == 1 then
    local lines = vim.fn.readfile(theme_file)
    if lines and lines[1] and vim.trim(lines[1]) ~= "" then
      return vim.trim(lines[1])
    end
  end
  return "tokyonight"
end

local colorscheme = read_system_colorscheme()

return {
  -- Catppuccin (all flavors registered automatically: catppuccin-latte/frappe/macchiato/mocha)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = not vim.startswith(colorscheme, "catppuccin"),
    priority = 1000,
  },

  -- Everforest (sainnhe's version, matching the theme palette author)
  {
    "sainnhe/everforest",
    lazy = colorscheme ~= "everforest",
    priority = 1000,
    init = function()
      vim.g.everforest_background = "hard"
      vim.o.background = "dark"
    end,
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = colorscheme ~= "gruvbox",
    priority = 1000,
    init = function()
      vim.o.background = "dark"
    end,
    opts = {},
  },

  -- tokyonight is already included by LazyVim; just set the active colorscheme
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = colorscheme
      return opts
    end,
  },
}
