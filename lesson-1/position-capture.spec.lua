local expression = require("position-capture")

describe("Summation expressions:", function()
  local cases = {
    { input = "12+13+25",                  expected = { "12", 3, "13", 6, "25" } },
    { input = "1+2",                       expected = { "1", 2, "2" } },
    { input = "1 + 2",                     expected = { "1", 3, "2" } },
    { input = "1+ 2 + 3+4",                expected = { "1", 2, "2", 6, "3", 9, "4" } },
    { input = "1 +2+ 3 + 4",               expected = { "1", 3, "2", 5, "3", 9, "4" } },
    { input = "1 + 2+3 + 4 + 5",           expected = { "1", 3, "2", 6, "3", 9, "4", 13, "5" } },
    { input = "1",                         expected = { } },
    { input = "1 +",                       expected = { } },
    { input = "1 + ",                      expected = { } },
    { input = "1 + 2 +",                   expected = { } },
    { input = "1 + 2 + ",                  expected = { } },
    { input = "1 + 2 + 3 +",               expected = { } },
    { input = "1 + 2 + 3 + ",              expected = { } },
    { input = "19 + 280 + 0047 + 63535 +", expected = { } },
    { input = " 1",                        expected = { } },
    { input = "+1",                        expected = { } },
    { input = " +1",                       expected = { } },
    { input = " + 1",                      expected = { } },
    { input = " ",                         expected = { } },
    { input = "\t",                        expected = { } },
    { input = "",                          expected = { } },
    { input = "a1 + 2",                    expected = { } }
  }

  for _, case in ipairs(cases) do
    it("'" .. case.input .. "' should match to " .. tostring(case.expected), function()
      local result = table.pack(expression:match(case.input))
      result.n = nil
      assert.same(case.expected, result)
    end)
  end
end)
