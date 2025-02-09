---@class Fade
---@overload fun(): Fade
Fade = Object:extend()

function Fade:new()
  self.progress = Progress(10)

  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setCenter(0, 0)
  self.sprite:setZIndex(Z_INDICES.fade)
  self.sprite:add()
end

---@param value boolean
function Fade:set(value)
  if value then
    self.progress:forward()
  else
    self.progress:backward()
  end
end

---@return pd_image
function Fade:render()
  local image = playdate.graphics.image.new(playdate.display.getWidth(), playdate.display.getHeight())
  playdate.graphics.pushContext(image)
  playdate.graphics.setColor(theme:foreground_color())
  playdate.graphics.fillCircleAtPoint(
    playdate.display.getWidth() / 2,
    playdate.display.getHeight() / 2,
    self.progress:progress() * 400
  )
  playdate.graphics.popContext()

  return image
end

function Fade:update()
  self.progress:update()

  if self.progress.changed then
    self.sprite:setImage(self:render())
  end
end
