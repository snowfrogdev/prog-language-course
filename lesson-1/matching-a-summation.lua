local lpeg = require("lpeg")

local space = lpeg.S(" \t") ^ 0
local number = space * lpeg.R("09") ^ 1 * space
local plus_operator = space * lpeg.P("+") * space
local expression = (number * plus_operator) ^ 1 * number

return expression
