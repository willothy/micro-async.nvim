local MiniTest = require("mini.test")

-- Define helper aliases
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

local a = require("micro-async")

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "build/test.lua" })
    end,
    post_once = child.stop,
  },
})

T["tasks"] = new_set()

T["tasks"]["it works"] = function()
  local done = false
  a.void(function()
    done = true
  end)()
  vim.wait(200, function()
    return done
  end)
  eq(done, true)
end

T["tasks"]["can be cancelled"] = function()
  local done = false
  local task = a.void(function()
    a.defer(200)
    done = true
  end)()
  task:cancel()
  vim.wait(300, function()
    return done
  end)
  eq(done, false)
end

return T
