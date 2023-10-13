local cwd = vim.uv.cwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:prepend(string.format("%s/build/mini.doc", cwd))

local MiniDoc = require("mini.doc")

MiniDoc.setup({})

local hooks = vim.deepcopy(MiniDoc.default_hooks)

hooks.write_pre = function(lines)
  -- Remove first two lines with `======` and `------` delimiters to comply
  -- with `:h local-additions` template
  table.remove(lines, 1)
  table.remove(lines, 1)
  return lines
end

MiniDoc.generate(
  { "lua/micro-async/init.lua" },
  "doc/micro-async.txt",
  { hooks = hooks }
)

local modules = {
  "uv",
  "lsp",
}

for _, m in ipairs(modules) do
  MiniDoc.generate(
    { "lua/micro-async/" .. m .. ".lua" },
    "doc/micro-async-" .. m .. ".txt",
    { hooks = hooks }
  )
end
