---@class Smooth
---@overload fun(value: number): Smooth
Smooth = Object:extend()

---@param value number
function Smooth:new(value)
  self.current_value = value
  self.target_value = value
end

---@return number
function Smooth:get()
  return self.current_value
end

function Smooth:set(value)
  self.target_value = value
end

function Smooth:update()
  self.current_value = self.current_value + (self.target_value - self.current_value) * 0.3

  if math.abs(self.current_value - self.target_value) < 1 then
    self.current_value = self.target_value
  end
end
