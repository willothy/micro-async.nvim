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

hooks.sections["@class"] = function(s)
  if #s == 0 or s.type ~= "section" then
    return
  end

  local name = s[1]:gsub(":.*", "")
  s[1] = name .. "\n"
  local tag = "*" .. name .. "*"

  local center_padding = 80 - #tag - #name
  local pad = (" "):rep(center_padding)

  s[1] = name .. pad .. tag
end

local prev_param = hooks.sections["@param"]
hooks.sections["@param"] = function(s)
  prev_param(s)
  if #s == 0 or s.type ~= "section" then
    return
  end
  s[1] = "\t" .. s[1]
end

local prev_return = hooks.sections["@return"]
hooks.sections["@return"] = function(s)
  prev_return(s)
  if #s == 0 or s.type ~= "section" then
    return
  end
  table.insert(s, 1, "")
  for i, v in ipairs(s) do
    if i > 2 then
      s[i] = "\t" .. v
    end
  end
end

local prev_text = hooks.sections["@text"]
hooks.sections["@text"] = function(s)
  prev_text(s)
  table.insert(s, 1, "")
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
