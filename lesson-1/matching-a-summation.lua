local lpeg = require("lpeg")

local space = lpeg.S(" \t") ^ 0
local numeral = space * lpeg.R("09") * space
local plus_operator = space * lpeg.P("+") * space
local expression = (numeral * plus_operator) ^ 1 * numeral

return expression
