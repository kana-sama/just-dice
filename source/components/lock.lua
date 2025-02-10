---@class Lock
---@overload fun(): Lock
Lock = Object:extend()

function Lock:new()
  self.progress = Progress(10)
  self.sprite = playdate.graphics.sprite.new()

  self.sprite:setCenter(0, 0)
  self.sprite:setZIndex(Z_INDICES.lock)
  self.sprite:add()
end

function Lock:update()
  self.progress:update()

  if playdate.isCrankDocked() then
    self.progress:backward()
  else
    self.progress:forward()
  end

  if self.progress.changed then
    self.sprite:setImage(self:render())
    self.sprite:moveTo(
      playdate.display.getWidth() - 30 + 50 * (1 - self.progress:subprogress(0, 0.8)),
      playdate.display.getHeight() - 40
    )
  end
end

---@return pd_image
function Lock:render()
  return playdate.graphics.image.render(20, 30, function()
    playdate.graphics.setColor(theme:foreground_color())
    playdate.graphics.fillRoundRect(0, 10, 20, 20, 5)
    playdate.graphics.setLineWidth(3)
    playdate.graphics.drawArc(10, 7 + 3 * self.progress:subprogress(0.8, 1), 6, -90, 90)
    playdate.graphics.drawLine(15, 6 + 3 * self.progress:subprogress(0.8, 1), 15, 16)
  end)
end

function Lock:is_unlocked()
  return playdate.isCrankDocked()
end
