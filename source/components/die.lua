local roll_effect = playdate.sound.sample.new("assets/audio/roll")
    or error("Failed to load 'assets/audio/roll.wav'")

local shake_effect = playdate.sound.sample.new("assets/audio/shake")
    or error("Failed to load 'assets/audio/shake.wav'")

---@alias die_value 1 | 2 | 3 | 4 | 5 | 6

---@class Die
---@field value die_value
---@field drawn_cache? { theme_version: number, value: die_value, angle: number, size: number }
---@overload fun(size: number): Die
Die = Object:extend()

---@param self Die
---@param size number
function Die:new(size)
  self.value = nil
  self.angle = nil
  self.drawn_cache = nil
  
  self.size = size
  self.position = playdate.geometry.point.new(0, 0)

  self.roll_animation = playdate.graphics.animator.new(500, 0, 1, playdate.easingFunctions.outCirc)

  self.roll_player = playdate.sound.sampleplayer.new(roll_effect)
  self.roll_player:setRate(0.8 + math.random() * 0.4)
  self.roll_player:setVolume(0.6 + math.random() * 0.4)

  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setZIndex(Z_INDICES.die)
  self.sprite:add()

  self:randomize()
end

function Die:randomize()
  self.value = math.random(6)
  self.angle = math.random(360)
  stat:add_die(self.value)
end

function Die:roll()
  self.roll_animation:reset()
  self:play_roll_effect()
end

function Die:play_roll_effect()
  local delay = 0.1 + math.random() * 0.2
  self.roll_player:setOffset(0.2)
  self.roll_player:playAt(playdate.sound.getCurrentTime() + delay)
end

function Die:play_shake_effect()
  local offset = math.random() * 0.05
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4

  shake_effect:playAt(playdate.sound.getCurrentTime() + offset, volume, nil, rate)
end

---@param value die_value
---@param size number
---@return pd_image die
function Die.render(value, size)
  local die = playdate.graphics.image.render(size, size, function()
    playdate.graphics.setColor(theme:foreground_color())
    playdate.graphics.fillRoundRect(0, 0, size, size, size / 5)

    playdate.graphics.setColor(theme:background_color())
    local radius = size * 0.1
    if value == 1 then
      playdate.graphics.fillCircleAtPoint(size / 2, size / 2, radius)
    elseif value == 2 then
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4 * 3, radius)
    elseif value == 3 then
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 2, size / 2, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4 * 3, radius)
    elseif value == 4 then
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4 * 3, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4 * 3, radius)
    elseif value == 5 then
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4 * 3, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4 * 3, radius)
      playdate.graphics.fillCircleAtPoint(size / 2, size / 2, radius)
    elseif value == 6 then
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4, radius)
      playdate.graphics.fillCircleAtPoint(size / 4, size / 4 * 3, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 4 * 3, radius)
      playdate.graphics.fillCircleAtPoint(size / 4, size / 2, radius)
      playdate.graphics.fillCircleAtPoint(size / 4 * 3, size / 2, radius)
    end
  end)

  return die
end

function Die:save_cache()
  self.drawn_cache = {
    theme_version = theme.version,
    angle = self.angle,
    value = self.value,
    size = self.size,
  }
end

function Die:is_cache_invalidated()
  return not self.drawn_cache
      or self.drawn_cache.theme_version ~= theme.version
      or self.drawn_cache.value ~= self.value
      or self.drawn_cache.angle ~= self.angle
      or self.drawn_cache.size ~= self.size
end

function Die:update()
  if self:is_cache_invalidated() then
    local image= Die.render(self.value, self.size)
    self.sprite:setImage(image:rotatedImage(self.angle))
    self:save_cache()
  end

  self.sprite:moveTo(
    self.position.x * self.roll_animation:currentValue(),
    self.position.y * self.roll_animation:currentValue()
  )
end

function Die:remove()
  self.sprite:remove()
end
