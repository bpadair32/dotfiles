local opt = vim.opt
local keymap = vim.keymap
opt.relativenumber = true
opt.number = true
keymap.set("i", "jk", "<ESC>")
opt.autoindent = true
