local expression = require("adding-more-operators")

describe("Additive Expressions:", function()
  local cases = {
    { input = "12+13+25",                  expected = 50 },
    { input = "1+2",                       expected = 3 },
    { input = "1 + 2",                     expected = 3 },
    { input = "1+ 2 + 3+4",                expected = 10 },
    { input = "1 +2+ 3 + 4",               expected = 10 },
    { input = "1 + 2+3 + 4 + 5",           expected = 15 },
    { input = "-1 + 2",                    expected = 1 },
    { input = "1 + -2",                    expected = -1 },
    { input = "+1 + -2",                   expected = -1 },
    { input = " 1",                        expected = 1 },
    { input = "1",                         expected = 1 },
    { input = "+1",                        expected = 1 },
    { input = " +1",                       expected = 1 },
    { input = "+ 1 + -2",                  expected = nil },
    { input = "--1 + 2",                   expected = nil },
    { input = "1 +",                       expected = nil },
    { input = "1 + ",                      expected = nil },
    { input = "1 + 2 +",                   expected = nil },
    { input = "1 + 2 + ",                  expected = nil },
    { input = "1 + 2 + 3 +",               expected = nil },
    { input = "1 + 2 + 3 + ",              expected = nil },
    { input = "19 + 280 + 0047 + 63535 +", expected = nil },
    { input = " + 1",                      expected = nil },
    { input = " ",                         expected = nil },
    { input = "\t",                        expected = nil },
    { input = "",                          expected = nil },
    { input = "a1 + 2",                    expected = nil },
    { input = "I like to move it 1 + 2",   expected = nil },
    { input = "1 + 2 something else",      expected = nil }
  }

  for _, case in ipairs(cases) do
    it("'" .. case.input .. "' should match to " .. tostring(case.expected), function()
      local result = expression:match(case.input)
      assert.are.equal(case.expected, result)
    end)
  end
end)

describe("Multiplicative and Additive Expressions:", function()
  local cases = {
    { input = "1 * 2 * 2 * 3 / 4",           expected = 3 },
    { input = "-1 * 2 * 2 * 3 / 4",          expected = -3 },
    { input = "7 % 3",                       expected = 1 },
    { input = "8 % 3 * 6 / 3 + 4 - 9 * -7",  expected = 71 },
    { input = "4 ^ 5",                       expected = 1024 },
    { input = "-1 * 2 + 6 ^ 3 % 4 - 8 / -2", expected = 2 }
  }

  for _, case in ipairs(cases) do
    it("'" .. case.input .. "' should match to " .. tostring(case.expected), function()
      local result = expression:match(case.input)
      assert.are.equal(case.expected, result)
    end)
  end
end)
