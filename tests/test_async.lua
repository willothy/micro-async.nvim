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

---@param set_name string
---@param set_fn fun()
local function describe(set_name, set_fn, parent)
  if not parent then
    parent = T
  end
  local set = new_set()
  parent[set_name] = set
  local env = getfenv(set_fn)
  env["it"] = function(name, test)
    set[name] = test
  end
  env["describe"] = function(name, child_set_fn)
    return describe(name, child_set_fn, set)
  end
  setfenv(set_fn, env)
  set_fn()
  return set
end

describe("run", function()
  it("throw exception in cb", function()
    -- expect assertion error thrown from `cb`
    expect.error(function()
      local done = false
      a.run(function()
        done = true
        return done
      end, function(returned_done)
        -- here throw assertion exception
        assert(not returned_done, "returned done must be false")
      end)
      vim.wait(200, function()
        return done
      end)
      eq(done, true)
    end)
  end)
end)

describe("tasks", function()
  it("works", function()
    local done = false
    a.void(function()
      done = true
    end)()
    vim.wait(200, function()
      return done
    end)
    eq(done, true)
  end)

  it("can be cancelled", function()
    local done = false
    local task = a.void(function()
      a.defer(200)
      done = true
    end)()
    task:cancel()
    vim.wait(300, function()
      return done
    end, 20, false)
    eq(done, false)
  end)
end)

describe("wrappers", function()
  describe("ui", function()
    describe("input", function() end)

    describe("select", function() end)
  end)

  describe("lsp", function()
    describe("buf_request", function() end)
  end)

  describe("uv", function() end)
end)

return T
