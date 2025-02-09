INITIAL_DIE_SIZE = 50

local roll_effect = playdate.sound.sample.new("assets/audio/roll")
    or error("Failed to load 'assets/audio/roll.wav'")

local shake_effect = playdate.sound.sample.new("assets/audio/shake")
    or error("Failed to load 'assets/audio/shake.wav'")

---@alias die_value 1 | 2 | 3 | 4 | 5 | 6

---@class Die
---@field value die_value
---@field drawn_cache? { theme_version: number, value: die_value, angle: number, size: number }
---@overload fun(): Die
Die = Object:extend()

Die.size = INITIAL_DIE_SIZE

---@param self Die
function Die:new()
  self.value = nil
  self.position = playdate.geometry.point.new(0, 0)
  self.angle = math.random(360)
  self.image = playdate.graphics.image.new(Die.size, Die.size)
  self.show_animation = playdate.graphics.animator.new(500, 0, 1, playdate.easingFunctions.outCirc)
  self.drawn_cache = nil

  self.roll_player = playdate.sound.sampleplayer.new(roll_effect)

  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setZIndex(Z_INDICES.die)
  self.sprite:add()
end

function Die:roll()
  self.value = math.random(6)
  self.show_animation:reset()
  self:play_roll_effect()
  stat:add_die(self.value)
end

function Die:play_roll_effect()
  local offset = 0.1 + math.random() * 0.1
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4
  self.roll_player:playAt(offset, volume, nil, rate)
end

function Die:play_shake_effect()
  local offset = math.random() * 0.05
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4

  shake_effect:playAt(offset, volume, nil, rate)
end

function Die:render()
  local image = playdate.graphics.image.new(Die.size, Die.size)

  playdate.graphics.pushContext(image)

  playdate.graphics.setColor(theme:foreground_color())
  playdate.graphics.fillRoundRect(0, 0, Die.size, Die.size, 15)

  playdate.graphics.setColor(theme:background_color())
  local radius = Die.size * 0.1
  if self.value == 1 then
    playdate.graphics.fillCircleAtPoint(Die.size / 2, Die.size / 2, radius)
  elseif self.value == 2 then
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4 * 3, radius)
  elseif self.value == 3 then
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 2, Die.size / 2, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4 * 3, radius)
  elseif self.value == 4 then
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4 * 3, radius)
  elseif self.value == 5 then
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 2, Die.size / 2, radius)
  elseif self.value == 6 then
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 4 * 3, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4, Die.size / 2, radius)
    playdate.graphics.fillCircleAtPoint(Die.size / 4 * 3, Die.size / 2, radius)
  end

  playdate.graphics.popContext()

  self.image = image:rotatedImage(self.angle)
  self.sprite:setImage(self.image)
  self:save_cache()
end

function Die:save_cache()
  self.drawn_cache = {
    theme_version = theme.version,
    angle = self.angle,
    value = self.value,
    size = Die.size,
  }
end

function Die:is_cache_invalidated()
  return not self.drawn_cache
      or self.drawn_cache.theme_version ~= theme.version
      or self.drawn_cache.value ~= self.value
      or self.drawn_cache.angle ~= self.angle
      or self.drawn_cache.size ~= Die.size
end

function Die:update()
  if self:is_cache_invalidated() then
    self:render()
  end

  self.sprite:moveTo(
    self.position.x * self.show_animation:currentValue(),
    self.position.y * self.show_animation:currentValue()
  )
end

function Die:remove()
  self.sprite:remove()
end
