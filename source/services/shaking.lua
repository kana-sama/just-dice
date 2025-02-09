local MAX_HISTORY_SIZE <const> = 10
local REQUIRED_SHAKE_FORCE <const> = 0.3
local SHAKE_DEBOUNCE <const> = 7
local EXTREMUM_DEBOUNCE <const> = 5

---@class Shaking
---@field history Vector3D[]
---@field is_shaking boolean
---@field is_start_shaking boolean
---@field is_stop_shaking boolean
---@field is_extremum boolean
Shaking = Object:extend()

function Shaking:new()
  self.history = {}

  self.is_shaking = false
  self.is_start_shaking = false
  self.is_stop_shaking = false
  self.is_extremum = false

  self.shake_debounce = 0
  self.extremum_debounce = 0
end

---@return Vector3D
function Shaking:last()
  return self.history[#self.history]
end

---@return Vector3D
function Shaking:prev()
  return self.history[#self.history - 1]
end

function Shaking:update()
  local x, y, z = playdate.readAccelerometer()
  table.insert(self.history, Vector3D(x, y, z))
  if #self.history > MAX_HISTORY_SIZE then
    table.remove(self.history, 1)
  end

  local average = Vector3D.zero()
  for i = 1, #self.history do
    average += self.history[i]
  end
  local average = #(average / #self.history)

  local total_delta_len = 0
  for i = 1, #self.history do
    total_delta_len += #self.history[i] - average
  end
  total_delta_len /= #self.history

  local is_shaking_right_now = total_delta_len > REQUIRED_SHAKE_FORCE

  if is_shaking_right_now ~= self.is_shaking then
    self.shake_debounce += 1
  else
    self.shake_debounce = 0
  end

  local is_shaking_prev = self.is_shaking

  if self.shake_debounce > SHAKE_DEBOUNCE then
    self.is_shaking = is_shaking_right_now
    self.shake_debounce = 0
  end

  self.is_start_shaking = not is_shaking_prev and self.is_shaking
  self.is_stop_shaking = is_shaking_prev and not self.is_shaking

  self.is_extremum = self.extremum_debounce <= 0
      and #self.history > 1
      and #(self:last() - self:prev()) > 0.5

  if self.is_extremum then
    self.extremum_debounce = EXTREMUM_DEBOUNCE
  else
    self.extremum_debounce -= 1
  end
end
