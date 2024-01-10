<div align="center">
  <h1>micro-async.nvim</h1>
</div>

Extremely simple async library for Neovim.

## Features

- One coroutine per task, minimal overhead
- Supports cancellation, with or without custom handles
- Simple interface to create custom async functions

## Installation

```lua
require("lazy").setup({
  --- ...
  { "willothy/micro-async.nvim" } -- no need to call setup()
})
```

## Usage

### `Task`

Top-level tasks are represented by a `Task` object. The `Task` type has three methods:

- `Task:resume(...):Cancellable?`: Resumes the task with the provided arguments (used internally, you shouldn't need to call this)
- `Task:cancel()`: Cancels the task, if it has not already been cancelled. Calls the running `Cancellable`'s `:cancel()` method, if any.
- `Task:is_cancelled():boolean`: Returns true if the task has been cancelled, false otherwise

When a top-level task is cancelled, in addition to calling the running `Cancellable`'s `:cancel()` method, no further calls to `Task:resume()` will resume a task's coroutine. Therefore, a cancelled task is effectively `"dead"` even if the status
of its coroutine is not `"dead"`, and any lingering sheduled / delayed resumes from non-cancelled luv handles will not cause a task to resume after cancellation.

Tasks can be created through two functions:

- `a.run(fn: fun(...):..., cb: fun(...)): Task`: Runs the provided function in an async context, and calls the callback with the result. Returns the created `Task` handle.
- `a.void(fn: fun(...)): fun(...): Task`: Creates a function that can be called from a non-async context, but cannot return any values as it is non-blocking. The resulting function returns a `Task`.

### `Cancellable`

Cancellable functions (mainly libuv functions that return `handles`) are implemented with a `Cancellable` interface, inspired by [`async.nvim`](https://github.com/lewis6991/async.nvim)'s `async_T`.

The `Cancellable` interface matches the cancellation API of top-level tasks, which allows top-level tasks to be used in place of `Cancellable` handles within nested tasks.

Creating a cancellable function is as simple as returning (or yielding, in an async context) a `handle` object that implements the `Cancellable` interface (see [examples](#examples)).

Required methods:

- `Cancellable:cancel()`: Cancels the running function, if it has not already been cancelled. Called internally by `Task:cancel()`.
- `Cancellable:is_cancelled():boolean`: Returns true if the call has been cancelled, false otherwise

### Examples

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

-- Cancel a task before it finishes
local task = a.void(function()
  a.defer(1000)
  vim.notify("Did not cancel", vim.log.levels.ERROR)
end)()
task:cancel()

-- Create wrap function on `vim.system` and yield value on exit.
-- The `callback` parameter is an additional parameter added to the end of wrapped function,
-- to yield value on `vim.system` exit.
local system_wrap = a.wrap(function(cmd, opts, callback)
  vim.system(cmd, opts, function(system_completed)
    callback(system_completed)
  end)
end, 3)
a.run(
  function()
    -- returns the yield value just like sync function.
    local system_completed = system_wrap({ "tokei", "--output", "json" }, { text = true })
    return system_completed
  end,
  function(system_completed)
    vim.print(vim.inspect(system_completed))
  end
)

-- Create your own cancellable function
-- Use `custom_defer` just like a normal async function. When
-- it is running and the top-level task is cancelled, its cancel()
-- function will be called.
--
-- This function should behave identically to `a.defer` in the above example
local function custom_defer(timeout)
  local timer = vim.defer_fn(timeout, a.callback())

  local handle = {}

  -- this is Cancellable:is_cancelled()
  function handle:is_cancelled()
    return timer:is_active()
  end

  -- this is Cancellable:cancel()
  function handle:cancel()
    if not timer:is_closing()
      timer:close()
    end
  end

  return coroutine.yield(handle)
end

-- Call any callback-style function asynchronously in a task,
-- without needing to wrap it previously in `a.wrap()`
local function stat_type(path)
  -- a.callback() creates a callback that resumes the current task
  -- this is how `a.wrap` resumes tasks internally
  local stat = vim.uv.fs_stat(path, a.callback())
  if stat then
    return stat.type
  end
end
```
