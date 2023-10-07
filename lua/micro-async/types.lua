---@meta

---@alias micro-async.SelectOpts { prompt: string?, format_item: nil|fun(item: any): string, kind: string? }

---@alias micro-async.InputOpts { prompt: string?, default: string?, completion: string?, highlight: fun(text: string) }

---@class micro-async.Task
---@field thread thread
---@field cancelled boolean
---@field cancel fun(self: micro-async.Task)
---@field resume fun(self: micro-async.Task, ...: any)
