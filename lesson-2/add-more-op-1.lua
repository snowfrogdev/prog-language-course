local lpeg = require "lpeg"
local pt = require "pt"

--------------------------------------------------------------------------------

local function node(num)
  return { tag = "number", val = tonumber(num) }
end

local function nodeHex(num)
  return { tag = "number", val = tonumber(num, 16) }
end

local space = lpeg.S(" \t\n") ^ 0
local hexDigit = lpeg.R("09", "af", "AF")
local hexNumber = '0' * lpeg.S("xX") * (hexDigit ^ 1 / nodeHex) * space
local decimal = lpeg.R("09") ^ 1 / node * space
local numeral = space * (hexNumber + decimal)

local opE = lpeg.C(lpeg.S "^") * space
local opA = lpeg.C(lpeg.S "+-") * space
local opM = lpeg.C(lpeg.S "*/%") * space

local function foldBin(lst)
  local tree = lst[1]
  for i = 2, #lst, 2 do
    tree = { tag = "binop", lhs = tree, op = lst[i], rhs = lst[i + 1] }
  end
  return tree
end

local pow = lpeg.Ct(numeral * (opE * numeral) ^ 0) / foldBin
local term = lpeg.Ct(pow * (opM * pow) ^ 0) / foldBin
local exp = lpeg.Ct(term * (opA * term) ^ 0) / foldBin

local function parse(input)
  return exp:match(input)
end

--------------------------------------------------------------------------------

local function addCode(state, op)
  local code = state.code
  code[#code + 1] = op
end

local ops = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
  ["%"] = "mod",
  ["^"] = "pow",
}

local function codeExp(state, ast)
  if ast.tag == "number" then
    addCode(state, "push")
    addCode(state, ast.val)
  elseif ast.tag == "binop" then
    codeExp(state, ast.lhs)
    codeExp(state, ast.rhs)
    addCode(state, ops[ast.op])
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
