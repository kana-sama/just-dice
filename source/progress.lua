---@class progress
---@field duration number
---@field is_forward boolean
---@field current_value number
---@overload fun(duration: number): progress
progress = Object:extend()

---@param duration number
function progress:new(duration)
  self.duration = duration
  self.is_forward = true
  self.current_value = 0
end

function progress:update()
  if self.is_forward then
    self.current_value += 1
  else
    self.current_value -= 1
  end

  self.current_value = math.max(0, math.min(self.duration, self.current_value))
end

function progress:forward()
  self.is_forward = true
end

function progress:backward()
  self.is_forward = false
end

-- @return number
function progress:progress()
  return self.current_value / self.duration
end