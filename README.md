# micro-async.nvim

Extremely simple async library for Neovim.

## Installation

```lua
require("lazy").setup({
  --- ...
  { "willothy/micro-async.nvim" } -- no need to call setup()
})
```

## Usage

```lua

local a = require("micro-async")

-- Run a function asynchronously and call the callback with the result.
a.run(
  function()
    -- run a system command
    local res = a.system({ "ls" }, {})

    -- wait 2 seconds
    a.defer(2000)

    -- return the result, calling the callback
    return res.stdout
  end,
  vim.print -- print the result
)

-- Yield to the scheduler to call the nvim API safely from luv callbacks
a.run(
  function()
    --- Use a timer to simulate resuming from a luv callback
    local t = vim.uv.new_timer()
    coroutine.yield(t:start(1000, 0, a.callback()))
    t:close()
    a.schedule() -- yield to `vim.schedule()` to ensure the nvim API is safe to call

    return vim.api.nvim_exec2("echo 'hello world'", { output = true }).output
  end,
  vim.print
)

-- Count lines of code using `tokei`, and format the output with `jq`
a.run(
  function()
    local tokei = a.system({ "tokei", "--output", "json" }, { text = true })

    if tokei.code ~= 0 then
      return tokei.stderr
    end

    local jq = a.system({ "jq" }, {
      text = true,
      stdin = tokei.stdout,
    })

    if jq.code ~= 0 then
      return jq.stderr
    end

    return jq.stdout
  end, 
  vim.print
)
```
