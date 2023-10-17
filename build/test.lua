local cwd = vim.uv.cwd()

if
  not vim.uv.fs_stat(cwd .. "/build/mini.test")
  or not vim.uv.fs_stat(cwd .. "/build/mini.test/lua/")
then
  print("cloning mini.test")
  vim.system({ "git", "submodule", "update", "--remote" }, {}):wait()
  print("done")
end

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
