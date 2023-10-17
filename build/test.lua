local uv = vim.uv or vim.loop

local cwd = uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:prepend(string.format("%s/build/mini.test", cwd))

local Test = require("mini.test")

Test.setup({
  execute = {
    reporter = Test.gen_reporter.stdout({
      group_depth = 99,
      quit_on_finish = true,
    }),
    stop_on_error = true,
  },
})
