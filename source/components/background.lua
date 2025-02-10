---@class Background
---@overload fun(): Background
Background = Object:extend()

function Background:new()
  self.dark_image = Background.render(dark_theme)
  self.light_image = Background.render(light_theme)

  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setCenter(0, 0)
  self.sprite:setZIndex(Z_INDICES.background)
  self.sprite:add()
end

---@param theme theme_values
---@return pd_image
function Background.render(theme)
  return playdate.graphics.image.render(playdate.display.getWidth(), playdate.display.getHeight(), function()
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
    playdate.graphics.clear()
    playdate.graphics.setPattern(theme.bg_pattern)
    playdate.graphics.fillRoundRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight(), 15)
  end)
end

function Background:update()
  if theme:is_dark_theme() then
    self.sprite:setImage(self.dark_image)
  else
    self.sprite:setImage(self.light_image)
  end
end
