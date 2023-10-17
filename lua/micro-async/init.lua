---@mod micro-async

local yield = coroutine.yield
local resume = coroutine.resume
local running = coroutine.running

---@private
---@type table<thread, micro-async.Task>
local handles = setmetatable({}, {
  __mode = "k",
})

---@private
local function is_async_task(task)
  return type(task) == "table"
    and vim.is_callable(task.cancel)
    and vim.is_callable(task.is_cancelled)
end

---@private
---@param fn fun(...): ...
---@return micro-async.Task
local function new_task(fn)
  local thread = coroutine.create(fn)
  local cancelled = false

  local task = {}
  local current = nil

  function task:cancel()
    if not cancelled then
      cancelled = true
      if current and not current:is_cancelled() then
        current:cancel()
      end
    end
  end

  function task:resume(...)
    if not cancelled then
      local _ok, rv = resume(thread, ...)
      if is_async_task(rv) then
        current = rv
      end
    end
  end

  handles[thread] = task

  return task
end

local Async = {}

---Create a callback function that resumes the current or specified coroutine when called.
---
---@param co thread | nil The thread to resume, defaults to the running one.
---@return fun(args:...)
function Async.callback(co)
  co = co or running()
  return function(...)
    handles[co]:resume(...)
  end
end

---Create a callback function that resumes the current or specified coroutine when called,
---and is wrapped in `vim.schedule` to ensure the API is safe to call.
---
---@param co thread | nil The thread to resume, defaults to the running one.
---@return fun(args:...)
function Async.scheduled_callback(co)
  co = co or running()
  return vim.schedule_wrap(function(...)
    handles[co]:resume(...)
  end)
end

---Create an async function that can be called from a synchronous context.
---Cannot return values as it is non-blocking.
---
---@return fun(...): micro-async.Task
---@param fn fun(...):...
function Async.void(fn)
  local task = new_task(fn)
  return function(...)
    task:resume(...)
    return task
  end
end

---Run a function asynchronously and call the callback with the result.
---
---@return micro-async.Task
---@param fn fun(...):...
---@param cb fun(...)
---@param ... any
function Async.run(fn, cb, ...)
  local task = new_task(function(...)
    cb(fn(...))
  end)
  task:resume(...)
  return task
end

---Wrap a callback-style function to be async.
---
---@param fn fun(...): ...any
---@param argc integer
---@return fun(...): ...
function Async.wrap(fn, argc)
  return function(...)
    local args = { ... }
    args[argc] = Async.callback()
    return yield(fn(unpack(args)))
  end
end

---Yields to the Neovim scheduler
---
---@async
function Async.schedule()
  return yield(vim.schedule(Async.callback()))
end

---Yields the current task, resuming when the specified timeout has elapsed.
---
---@async
---@param timeout integer
function Async.defer(timeout)
  yield({
    ---@type uv_timer_t
    timer = vim.defer_fn(Async.callback(), timeout),
    cancel = function(self)
      if not self.timer:is_closing() then
        if self.timer:is_active() then
          self.timer:stop()
        end
        self.timer:close()
      end
    end,
    is_cancelled = function(self)
      return self.timer:is_closing()
    end,
  })
end

---Wrapper that creates and queues a work request, yields, and resumes the current task with the results.
---
---@async
---@param fn fun(...):...
---@param ... ...uv.aliases.threadargs
---@return ...uv.aliases.threadargs
function Async.work(fn, ...)
  local uv = require("micro-async.uv")
  return uv.queue_work(uv.new_work(fn), ...)
end

---Async vim.system
---
---@async
---@param cmd string[] Command to run
---@param opts table Options to pass to `vim.system`
Async.system = function(cmd, opts)
  return yield(vim.system(cmd, opts, Async.callback()))
end

---@module "micro-async.lsp"
Async.lsp = nil

---@module "micro-async.uv"
Async.uv = nil

Async.ui = {}

---@async
---@param items any[]
---@param opts micro-async.SelectOpts
---@return any?, integer?
Async.ui.select = function(items, opts)
  vim.ui.select(items, opts, Async.callback())

  local win = vim.api.nvim_get_current_win()

  local cancelled = false
  return yield({
    cancel = function()
      vim.api.nvim_win_close(win, true)
      cancelled = true
    end,
    is_cancelled = function()
      return cancelled
    end,
  })
end

---@async
---@param opts micro-async.InputOpts
---@return string?
Async.ui.input = function(opts)
  return yield(vim.ui.input(opts, Async.scheduled_callback()))
end

setmetatable(Async, {
  __index = function(_, k)
    local ok, mod = pcall(require, "micro-async." .. k)
    if ok then
      return mod
    end
  end,
})

return Async
