DIE_SIZE = 50

local roll_effect = playdate.sound.sample.new("audio/roll")
  or error("Failed to load audio/roll.wav")

local shake_effect = playdate.sound.sample.new("audio/shake")
  or error("Failed to load audio/shake.wav")

---@alias die_value 1 | 2 | 3 | 4 | 5 | 6

---@class die
---@field value die_value
---@field position pd_point
---@field angle number
---@field image pd_image
---@field show_animation pd_animator
---@field drawn_cache? { theme_version: number, value: die_value, angle: number }
---@overload fun(): die
die = Object:extend()

function die:new()
  self.value = math.random(6)
  self.position = playdate.geometry.point.new(0, 0)
  self.angle = math.random(360)
  self.image = playdate.graphics.image.new(DIE_SIZE, DIE_SIZE)
  self.show_animation = playdate.graphics.animator.new(500, 0, 1, playdate.easingFunctions.outCirc)
  self.drawn_with_version = theme.version
  self.drawn_cache = nil
end

function die:roll()
  self.value = math.random(6)
  self.show_animation:reset()
  self:play_roll_effect()
end

function die:play_roll_effect()
  local offset = 0.1 + math.random() * 0.1
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4

  roll_effect:playAt(offset, volume, nil, rate)
end

function die:play_shake_effect()
  local offset = math.random() * 0.05
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4

  shake_effect:playAt(offset, volume, nil, rate)
end

function die:render()
  local image = playdate.graphics.image.new(DIE_SIZE, DIE_SIZE)

  playdate.graphics.pushContext(image)

  playdate.graphics.setColor(theme:foreground_color())
  playdate.graphics.fillRoundRect(0, 0, DIE_SIZE, DIE_SIZE, 15)

  playdate.graphics.setColor(theme:background_color())
  local radius = DIE_SIZE * 0.1
  if self.value == 1 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, radius)
  elseif self.value == 2 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, radius)
  elseif self.value == 3 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, radius)
  elseif self.value == 4 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, radius)
  elseif self.value == 5 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, radius)
  elseif self.value == 6 then
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 2, radius)
    playdate.graphics.fillCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 2, radius)
  end

  playdate.graphics.popContext()

  self.image = image:rotatedImage(self.angle)
  self.drawn_cache = {
    theme_version = theme.version,
    angle = self.angle,
    value = self.value,
  }
end

function die:is_cache_invalidated()
  return not self.drawn_cache
    or self.drawn_cache.theme_version ~= theme.version
    or self.drawn_cache.value ~= self.value
    or self.drawn_cache.angle ~= self.angle
end

function die:draw()
  if self:is_cache_invalidated() then
    self:render()
  end

  self.image:drawCentered(
    self.position.x * self.show_animation:currentValue(),
    self.position.y * self.show_animation:currentValue()
  )
end