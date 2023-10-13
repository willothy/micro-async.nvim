local cwd = vim.uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:prepend(string.format("%s/build/mini.test", cwd))

require("mini.test").setup({})
