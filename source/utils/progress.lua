---@class Progress
---@field duration number
---@field is_forward boolean
---@field current_value number
---@overload fun(duration: number): Progress
Progress = Object:extend()

---@param duration number
function Progress:new(duration)
  self.duration = duration
  self.is_forward = true
  self.current_value = 0
  self.changed = false
end

function Progress:update()
  self.changed = false

  if self.is_forward and self.current_value < self.duration then
    self.current_value += 1
    self.changed = true
  end

  if not self.is_forward and self.current_value > 0 then
    self.current_value -= 1
    self.changed = true
  end
end

function Progress:forward()
  self.is_forward = true
end

function Progress:backward()
  self.is_forward = false
end

---@return number
function Progress:progress()
  return self.current_value / self.duration
end

--- Maps the part of the progress between `from` and `to` to the range [0, 1].
---
---@param from number
---@param to number
---@return number
function Progress:subprogress(from, to)
  local value = self:progress()

  if value < from then
    return 0
  end

  if value > to then
    return 1
  end

  return (value - from) / (to - from)
end