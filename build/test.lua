local cwd = vim.uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:prepend(string.format("%s/build/mini.test", cwd))

local Test = require("mini.test")

Test.setup({
  execute = {
    reporter = Test.gen_reporter.stdout({
      group_depth = 99,
    }),
    stop_on_error = true,
  },
})
