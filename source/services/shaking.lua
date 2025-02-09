local MAX_HISTORY_SIZE <const> = 10
local REQUIRED_SHAKE_FORCE <const> = 0.3
local SHAKE_DEBOUNCE <const> = 7
local EXTREMUM_DEBOUNCE <const> = 5

---@class Shaking
---@field history RingBuffer<Vector3D>
---@field is_shaking boolean
---@field is_start_shaking boolean
---@field is_stop_shaking boolean
---@field is_extremum boolean
Shaking = Object:extend()

function Shaking:new()
  self.history = RingBuffer(MAX_HISTORY_SIZE, Vector3D.zero)

  self.is_shaking = false
  self.is_start_shaking = false
  self.is_stop_shaking = false
  self.is_extremum = false

  self.shake_debounce = 0
  self.extremum_debounce = 0
end

function Shaking:update()
  local x, y, z = playdate.readAccelerometer()
  self.history:push(Vector3D(x or 0, y or 0, z or 0))

  local average = #self.history:average()
  local total_delta_len = 0
  for _, shake in ipairs(self.history.buffer) do
    total_delta_len += #shake - average
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

  self.is_extremum = true
      and self.extremum_debounce <= 0
      and #(self.history:last() - self.history:prev()) > 0.5

  if self.is_extremum then
    self.extremum_debounce = EXTREMUM_DEBOUNCE
  else
    self.extremum_debounce -= 1
  end
end
