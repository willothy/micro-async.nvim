local done = false
coroutine.resume(coroutine.create(function()
  local uv = vim.uv or vim.loop

  local cwd = uv.cwd()

  if
    not uv.fs_stat(cwd .. "/build/mini.test")
    or not uv.fs_stat(cwd .. "/build/mini.test/lua/")
  then
    print("cloning mini.test")
    local co = coroutine.running()
    coroutine.yield(uv.spawn(
      "git",
      {
        args = { "submodule", "update", "--remote" },
      },
      vim.schedule_wrap(function(...)
        coroutine.resume(co, ...)
      end)
    ))
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
  done = true
end))

vim.wait(10000, function()
  return done
end)

_G.MiniTest = require("mini.test")
