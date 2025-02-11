---@class Background
---@overload fun(): Background
Background = Object:extend()

function Background:new()
  self.prerenderd = {
    dark = {
      with_pattern = Background.render(dark_theme, true),
      without_pattern = Background.render(dark_theme, false)
    },
    light = {
      with_pattern = Background.render(light_theme, true),
      without_pattern = Background.render(light_theme, false)
    }
  }

  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setCenter(0, 0)
  self.sprite:setZIndex(Z_INDICES.background)
  self.sprite:add()
end

---@param theme theme_values
---@param pattern boolean
---@return pd_image
function Background.render(theme, pattern)
  return playdate.graphics.image.render(playdate.display.getWidth(), playdate.display.getHeight(), function()
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
    playdate.graphics.clear()

    if pattern then
      playdate.graphics.setPattern(theme.bg_pattern)
    else
      playdate.graphics.setColor(theme.bg)
    end

    playdate.graphics.fillRoundRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight(), 15)
  end)
end

function Background:update()
  local theme = theme:is_dark_theme() and "dark" or "light"
  local pattern = config.stored.pattern and "with_pattern" or "without_pattern"
  self.sprite:setImage(self.prerenderd[theme][pattern])
end
