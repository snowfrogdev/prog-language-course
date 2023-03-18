local expression = require("matching-a-summation")

describe("Summation expressions:", function()
  local cases = {
    {input = "1+2", expected = 4},
    {input = "1 + 2", expected = 6},
    {input = "1+ 2 + 3+4", expected = 11},
    {input = "1 +2+ 3 + 4", expected = 12},
    {input = "1 + 2+3 + 4 + 5", expected = 16},
    {input = "1", expected = nil},
    {input = "1 +", expected = nil},
    {input = "1 + ", expected = nil},
    {input = "1 + 2 +", expected = nil},
    {input = "1 + 2 + ", expected = nil},
    {input = "1 + 2 + 3 +", expected = nil},
    {input = "1 + 2 + 3 + ", expected = nil},
    {input = " 1", expected = nil},
    {input = "+1", expected = nil},
    {input = " +1", expected = nil},
    {input = " + 1", expected = nil},
    {input = " ", expected = nil},
    {input = "\t", expected = nil},
    {input = "", expected = nil},
    {input = "a1 + 2", expected = nil}
  }

  for _, case in ipairs(cases) do
    it("'" ..case.input .. "' should match to " .. tostring(case.expected), function()
      local result = expression:match(case.input)
      assert.are.equal(case.expected, result)
    end)
  end
end)