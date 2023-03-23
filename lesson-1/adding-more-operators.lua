local lpeg = require("lpeg")

local space = lpeg.S(" \n\t") ^ 0
local unary = lpeg.S("+-") ^ -1
local numeral = (unary * lpeg.R("09") ^ 1 / tonumber) * space
local opA = lpeg.C(lpeg.S "+-") * space
local opM = lpeg.C(lpeg.S "*/%") * space
local opE = lpeg.C(lpeg.P "^") * space

local function fold(lst)
  local acc = lst[1]
  for i = 2, #lst, 2 do
    if lst[i] == "+" then
      acc = acc + lst[i + 1]
    elseif lst[i] == "-" then
      acc = acc - lst[i + 1]
    elseif lst[i] == "*" then
      acc = acc * lst[i + 1]
    elseif lst[i] == "/" then
      acc = acc / lst[i + 1]
    elseif lst[i] == "%" then
      acc = acc % lst[i + 1]
    elseif lst[i] == "^" then
      acc = acc ^ lst[i + 1]
    else
      error("Unknown operator: " .. lst[i])
    end
  end
  return acc
end

local exponent = space * lpeg.Ct(numeral * (opE * numeral) ^ 0) / fold
local term = space * lpeg.Ct(exponent * (opM * exponent) ^ 0) / fold
local expression = space * lpeg.Ct(term * (opA * term) ^ 0) / fold * -1

return expression
