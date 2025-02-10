---@generic T
---@param list T[]
---@param ix integer
---@return T
function table.remove_elem(list, ix)
  return table.remove(list, ix)
end