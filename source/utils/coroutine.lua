---@param action async fun()
---@return thread
function coroutine.forever(action)
  return coroutine.create(function()
    while true do
      local co = coroutine.create(action)
      
      repeat
        local ok, err = coroutine.resume(co)
        if not ok then error(err) end

        coroutine.yield()
      until coroutine.status(co) == "dead"
    end
  end)
end