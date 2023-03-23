local lpeg = require("lpeg")

local space = lpeg.S(" \n\t") ^ 0
local unary_operator = lpeg.S("+-") ^ -1
local number = lpeg.C(unary_operator * lpeg.R("09") ^ 1) * space
local plus_operator = lpeg.Cp() * lpeg.P("+") * space
local expression = (space * number * plus_operator) ^ 1 * number * -1

return expression
