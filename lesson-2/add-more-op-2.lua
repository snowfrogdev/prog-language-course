local lpeg = require "lpeg"
local pt = require "pt"

--------------------------------------------------------------------------------

local function node(num)
  return { tag = "number", val = tonumber(num) }
end

local function nodeHex(num)
  return { tag = "number", val = tonumber(num, 16) }
end

local function foldBin(lst)
  local tree = lst[1]
  for i = 2, #lst, 2 do
    tree = { tag = "binop", lhs = tree, op = lst[i], rhs = lst[i + 1] }
  end
  print(pt.pt(lst))
  return tree
end

local function foldUnary(lst)
  if #lst == 2 then
    return { tag = "unary", op = lst[1], rhs = lst[2] }
  else
    return lst[1]
  end
end


local exp = lpeg.V "exp"
local compExp = lpeg.V "compExp"
local opC = lpeg.V "opC"
local addExp = lpeg.V "addExp"
local opA = lpeg.V "opA"
local multExp = lpeg.V "multExp"
local opM = lpeg.V "opM"
local powExp = lpeg.V "powExp"
local opE = lpeg.V "opE"
local unary = lpeg.V "unary"
local opU = lpeg.V "opU"
local primary = lpeg.V "primary"
local OP = lpeg.V "OP"
local CP = lpeg.V "CP"
local number = lpeg.V "number"
local decimalNumber = lpeg.V "decimalNumber"
local hexNumber = lpeg.V "hexNumber"
local space = lpeg.S(" \t\n\r") ^ 0

local grammar = lpeg.P { "exp",
  exp = compExp,
  compExp = lpeg.Ct(addExp * (opC * addExp) ^ 0) / foldBin,
  opC = lpeg.C(lpeg.P(">=") + "<=" + "==" + "!=" + lpeg.S("><")) * space,
  addExp = lpeg.Ct(multExp * (opA * multExp) ^ 0) / foldBin,
  opA = lpeg.C(lpeg.S "+-") * space,
  multExp = lpeg.Ct(powExp * (opM * powExp) ^ 0) / foldBin,
  opM = lpeg.C(lpeg.S "*/%") * space,
  powExp = lpeg.Ct(unary * (opE * unary) ^ 0) / foldBin,
  opE = lpeg.C("^") * space,
  unary = lpeg.Ct((opU * primary) + primary) / foldUnary,
  opU = lpeg.C("-") * space,
  primary = number + OP * exp * CP,
  OP = "(" * space,
  CP = ")" * space,
  number = hexNumber + decimalNumber,
  decimalNumber = lpeg.R("09") ^ 1 / node * space,
  hexNumber = '0' * lpeg.S("xX") * (lpeg.R("09", "af", "AF") ^ 1 / nodeHex) * space,
}

grammar = space * grammar * -1

local function parse(input)
  return grammar:match(input)
end

--------------------------------------------------------------------------------

local function addCode(state, op)
  local code = state.code
  code[#code + 1] = op
end

local unOps = {
  ["-"] = "neg",
}

local binOps = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
  ["%"] = "mod",
  ["^"] = "pow",
  [">"] = "gt",
  ["<"] = "lt",
  [">="] = "ge",
  ["<="] = "le",
  ["=="] = "eq",
  ["!="] = "ne",
}

local function codeExp(state, ast)
  if ast.tag == "number" then
    addCode(state, "push")
    addCode(state, ast.val)
  elseif ast.tag == "unary" then
    codeExp(state, ast.rhs)
    addCode(state, unOps[ast.op])
  elseif ast.tag == "binop" then
    codeExp(state, ast.lhs)
    codeExp(state, ast.rhs)
    addCode(state, binOps[ast.op])
  else
    error("invalid tree")
  end
end

local function compile(ast)
  local state = { code = {} }
  codeExp(state, ast)
  return state.code
end

--------------------------------------------------------------------------------

local function run(code, stack)
  local pc = 1
  local top = 0
  while pc <= #code do
    local str = "Executing: "
    if code[pc] == "push" then
      print(str .. "push " .. code[pc + 1])
      pc = pc + 1
      top = top + 1
      stack[top] = code[pc]
    elseif code[pc] == "neg" then
      print(str .. "negating " .. stack[top])
      stack[top] = -stack[top]
    elseif code[pc] == "pow" then
      print(str .. stack[top - 1] .. " ^ " .. stack[top])
      stack[top - 1] = stack[top - 1] ^ stack[top]
      top = top - 1
    elseif code[pc] == "mul" then
      print(str .. stack[top - 1] .. " * " .. stack[top])
      stack[top - 1] = stack[top - 1] * stack[top]
      top = top - 1
    elseif code[pc] == "div" then
      print(str .. stack[top - 1] .. " / " .. stack[top])
      stack[top - 1] = stack[top - 1] / stack[top]
      top = top - 1
    elseif code[pc] == "mod" then
      print(str .. stack[top - 1] .. " % " .. stack[top])
      stack[top - 1] = stack[top - 1] % stack[top]
      top = top - 1
    elseif code[pc] == "add" then
      print(str .. stack[top - 1] .. " + " .. stack[top])
      stack[top - 1] = stack[top - 1] + stack[top]
      top = top - 1
    elseif code[pc] == "sub" then
      print(str .. stack[top - 1] .. " - " .. stack[top])
      stack[top - 1] = stack[top - 1] - stack[top]
      top = top - 1
    elseif code[pc] == "gt" then
      print(str .. stack[top - 1] .. " > " .. stack[top])
      stack[top - 1] = (stack[top - 1] > stack[top]) and 1 or 0
      top = top - 1
    elseif code[pc] == "lt" then
      print(str .. stack[top - 1] .. " < " .. stack[top])
      stack[top - 1] = (stack[top - 1] < stack[top]) and 1 or 0
      top = top - 1
    elseif code[pc] == "ge" then
      print(str .. stack[top - 1] .. " >= " .. stack[top])
      stack[top - 1] = (stack[top - 1] >= stack[top]) and 1 or 0
      top = top - 1
    elseif code[pc] == "le" then
      print(str .. stack[top - 1] .. " <= " .. stack[top])
      stack[top - 1] = (stack[top - 1] <= stack[top]) and 1 or 0
      top = top - 1
    elseif code[pc] == "eq" then
      print(str .. stack[top - 1] .. " == " .. stack[top])
      stack[top - 1] = (stack[top - 1] == stack[top]) and 1 or 0
      top = top - 1
    elseif code[pc] == "ne" then
      print(str .. stack[top - 1] .. " != " .. stack[top])
      stack[top - 1] = (stack[top - 1] ~= stack[top]) and 1 or 0
      top = top - 1
    else
      error("unknown instruction")
    end
    pc = pc + 1
  end
end

local input = io.read("a")
local ast = parse(input)
print(pt.pt(ast))
local code = compile(ast)
print(pt.pt(code))
local stack = {}
run(code, stack)
print(stack[1])
