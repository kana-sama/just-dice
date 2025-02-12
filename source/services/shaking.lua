local MAX_HISTORY_SIZE <const> = 10
local REQUIRED_SHAKE_FORCE <const> = 0.3
local SHAKE_DEBOUNCE <const> = 7
local EXTREMUM_DEBOUNCE <const> = 5

---@class Shaking
---@field history RingBuffer<Vector3D>
---@field is_going_on boolean
---@field is_just_started boolean
---@field is_just_stopped boolean
---@field is_on_extremum boolean
---@overload fun(): Shaking
Shaking = Object:extend()

function Shaking:new()
  self.history = RingBuffer(MAX_HISTORY_SIZE, Vector3D.zero)

  self.is_going_on = false
  self.is_just_started = false
  self.is_just_stopped = false
  self.is_on_extremum = false

  self.shake_debounce = 0
  self.extremum_debounce = 0
end

function Shaking:update()
  local x, y, z = playdate.readAccelerometer()
  self.history:push(Vector3D(x or 0, y or 0, z or 0))

  local average = #self.history:average()
  local total_delta_len = 0
  for i = 1, #self.history do
    total_delta_len += #self.history.buffer[i] - average
  end
  total_delta_len /= #self.history

  local is_shaking_right_now = total_delta_len > REQUIRED_SHAKE_FORCE

  if is_shaking_right_now ~= self.is_going_on then
    self.shake_debounce += 1
  else
    self.shake_debounce = 0
  end

  local is_shaking_prev = self.is_going_on

  if self.shake_debounce > SHAKE_DEBOUNCE then
    self.is_going_on = is_shaking_right_now
    self.shake_debounce = 0
  end

  self.is_just_started = not is_shaking_prev and self.is_going_on
  self.is_just_stopped = is_shaking_prev and not self.is_going_on

  self.is_on_extremum = true
      and self.extremum_debounce <= 0
      and #(self.history:last() - self.history:prev()) > 0.5

  if self.is_on_extremum then
    self.extremum_debounce = EXTREMUM_DEBOUNCE
  else
    self.extremum_debounce -= 1
  end
end
