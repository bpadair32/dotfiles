return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<CR>"] = {},
      ["<S-CR>"] = { "select_and_accept", "fallback" },
      ["<Tab>"] = { "accept", "select_next", "fallback" },
    },
  },
}
