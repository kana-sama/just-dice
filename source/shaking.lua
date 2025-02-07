---@class shaking
---@field last_accels vector3D[]
shaking = {
  last_accels = {};
  is_shaking = false;
  is_start_shaking = false;
  is_stop_shaking = false;
  is_extremum = false;
  debounce = 0;
}

function shaking:update()
  playdate.startAccelerometer()

  local x, y, z = playdate.readAccelerometer()
  table.insert(self.last_accels, vector3D(x, y, z))
  if #self.last_accels > 10 then
    table.remove(self.last_accels, 1)
  end

  local average = vector3D.zero()
  for i = 1, #self.last_accels do
    average += self.last_accels[i]
  end
  local average = #(average / #self.last_accels)

  local total_delta_len = 0
  for i = 1, #self.last_accels do
    total_delta_len += #self.last_accels[i] - average
  end
  total_delta_len /= #self.last_accels

  local is_shaking_right_now = total_delta_len > 0.5

  if is_shaking_right_now ~= self.is_shaking then
    self.debounce += 1
  else
    self.debounce = 0
  end

  local is_shaking_prev = self.is_shaking

  if self.debounce > 10 then
    self.is_shaking = is_shaking_right_now
    self.debounce = 0
  end

  self.is_start_shaking = not is_shaking_prev and self.is_shaking;
  self.is_stop_shaking = is_shaking_prev and not self.is_shaking;
  self.is_extremum = #self.last_accels > 2
    and #self.last_accels[#self.last_accels] < #self.last_accels[#self.last_accels-1]
    and #self.last_accels[#self.last_accels-1] > #self.last_accels[#self.last_accels-2]
end