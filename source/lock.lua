---@param value number
---@param from number
---@param to number
---@return number
local function interval(value, from, to)
  if value < from then
    return 0
  end

  if value > to then
    return 1
  end

  return (value - from) / (to - from)
end

---@class lock
lock = {
  progress = progress(10),
  is_locked = false,
  is_unlocked = true,
}

function lock:update()
  self.progress:update()

  if playdate.isCrankDocked() then
    self.is_locked = false
    self.progress:backward()
  else
    self.is_locked = true
    self.progress:forward()
  end

  self.is_unlocked = not self.is_locked
end

function lock:draw()
  local lock_image = playdate.graphics.image.new(20, 30)
  playdate.graphics.pushContext(lock_image)
  playdate.graphics.fillRoundRect(0, 10, 20, 20, 5)
  playdate.graphics.setLineWidth(3)
  playdate.graphics.drawArc(10, 7 + 3 * interval(self.progress:progress(), 0.8, 1), 6, -90, 90)
  playdate.graphics.drawLine(15, 6 + 3 * interval(self.progress:progress(), 0.8, 1), 15, 16)
  playdate.graphics.popContext()
  lock_image:draw(playdate.display.getWidth() - 30 + 50 * (1 - interval(self.progress:progress(), 0, 0.8)), playdate.display.getHeight() - 40)
end