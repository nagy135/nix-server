local abbreviations = {
  W = "w",
  Q = "q",
  Wq = "wq",
  wQ = "wq",
  Qa = "qa",
  wQa = "wqa",
  Wqa = "wqa",
  wqA = "wqa",
  WQa = "wqa",
  wQA = "wqa",
  WQA = "wqa",
  E = "e",
}

for lhs, rhs in pairs(abbreviations) do
  vim.cmd(("cnoreabbrev %s %s"):format(lhs, rhs))
end
