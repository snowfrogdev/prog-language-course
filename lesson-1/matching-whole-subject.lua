local lpeg = require("lpeg")

local space = lpeg.S(" \t") ^ 0
local number = space * lpeg.C(lpeg.R("09") ^ 1) * space
local plus_operator = space * lpeg.Cp() * lpeg.P("+") * space
local expression = (number * plus_operator) ^ 1 * number * -1

return expression
