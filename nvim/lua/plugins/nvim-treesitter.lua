return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    vim.filetype.add({
      pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
    }),
  },
}
