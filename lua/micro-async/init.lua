---@mod micro-async

local yield = coroutine.yield
local resume = coroutine.resume
local running = coroutine.running

---@type table<thread, micro-async.Task>
local handles = setmetatable({}, {
	__mode = "k",
})

---@param fn fun(...): ...
---@return micro-async.Task
local function new_task(fn)
	local thread = coroutine.create(fn)
	local cancelled = false

	local task = {}

	function task:cancel()
		cancelled = true
	end

	function task:resume(...)
		if not cancelled then
			resume(thread, ...)
		end
	end

	handles[thread] = task

	return task
end

local M = {}

---Create a callback function that resumes the current or specified coroutine when called.
---
---@param co thread | nil The thread to resume, defaults to the running one.
---@return fun(args:...)
function M.callback(co)
	co = co or running()
	return function(...)
		handles[co]:resume(...)
	end
end

---Create an async function that can be called from a synchronous context.
---Cannot return values as it is non-blocking.
---
---@return fun(args:...): micro-async.Task
---@param fn fun(args:...):...
function M.void(fn)
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
function M.run(fn, cb, ...)
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
function M.wrap(fn, argc)
	return function(...)
		local args = { ... }
		args[argc] = M.callback()
		return yield(fn(unpack(args)))
	end
end

---Yields to the Neovim scheduler
---
---@async
function M.schedule()
	return yield(vim.schedule(M.callback()))
end

---Yields the current task, resuming when the specified timeout has elapsed.
---
---@async
---@param timeout integer
function M.defer(timeout)
	yield(vim.defer_fn(M.callback(), timeout))
end

---Wrapper that creates and queues a work request, yields, and resumes the current task with the results.
---
---@async
---@param fn fun(...):...
---@param ... ...uv.aliases.threadargs
---@return ...uv.aliases.threadargs
function M.work(fn, ...)
	local uv = require("micro-async.uv")
	return uv.queue_work(uv.new_work(fn), ...)
end

---Async vim.system
---
---@async
---@param cmd string[] Command to run
---@param opts table Options to pass to `vim.system`
M.system = function(cmd, opts)
	return yield(vim.system(cmd, opts, M.callback()))
end

---@module "micro-async.lsp"
M.lsp = nil

---@module "micro-async.uv"
M.uv = nil

M.ui = {}

---@async
---@param items any[]
---@param opts micro-async.SelectOpts
---@return any?, integer?
M.ui.select = function(items, opts)
	return yield(vim.ui.select(items, opts, M.callback()))
end

---@async
---@param opts micro-async.InputOpts
---@return string?
M.ui.input = function(opts)
	return yield(vim.ui.input(opts, M.callback()))
end

setmetatable(M, {
	__index = function(_, k)
		local ok, mod = pcall(require, "micro-async." .. k)
		if ok then
			return mod
		end
	end,
})

return M
