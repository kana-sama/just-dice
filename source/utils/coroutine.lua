---@param action async fun()
---@return thread
function coroutine.forever(action)
  return coroutine.create(function()
    while true do
      local co = coroutine.create(action)
      
      repeat
        coroutine.resume(co)
        coroutine.yield()
      until coroutine.status(co) == "dead"
    end
  end)
end