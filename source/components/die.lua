roll_effects = {
  one = playdate.sound.sample.new("assets/audio/roll-one")
      or error("Failed to load 'assets/audio/roll-one.wav'");
  some = playdate.sound.sample.new("assets/audio/roll-some")
      or error("Failed to load 'assets/audio/roll-some.wav'");
  many = playdate.sound.sample.new("assets/audio/roll-many")
      or error("Failed to load 'assets/audio/roll-many.wav'");
}

local shake_effect = playdate.sound.sample.new("assets/audio/shake")
    or error("Failed to load 'assets/audio/shake.wav'")

local prerendered = playdate.graphics.imagetable.new("assets/images/dice")
    or error("Failed to load 'assets/images/dice-table-*-*.gif'")


local ROLL_ANIMATION_DURATION <const> = 500
local REMOVE_ANIMATION_DURATION <const> = 300
local HIGHLIGHT_ANIMATION_DURATION <const> = 15
local HIGHLIGHT_HIGHT <const> = 4
local FLOATING_OFFSET <const> = 3


---@alias die_value 1 | 2 | 3 | 4 | 5 | 6

---@class Die
---@field value die_value
---@field drawn_cache? { theme_version: number, value: die_value, angle: number, size: number }
---@overload fun(size: number): Die
Die = Object:extend()

Die.roll_effects = roll_effects

Die.floating_animation =  playdate.graphics.animator.new(700, -FLOATING_OFFSET/2, FLOATING_OFFSET/2, playdate.easingFunctions.inOutQuad)
Die.floating_animation.reverses = true
Die.floating_animation.repeatCount = -1

---@param self Die
---@param size number
function Die:new(size)
  self.value = nil
  self.drawn_cache = nil
  
  self.angle = 0
  self.size = size
  self.position = playdate.geometry.point.new(0, 0)

  self.roll_animation = playdate.graphics.animator.new(ROLL_ANIMATION_DURATION, 0, 1, playdate.easingFunctions.outCirc)
  self.remove_animation = playdate.graphics.animator.disabled(0)

  self.die_sprite = playdate.graphics.sprite.new()
  self.die_sprite:setZIndex(Z_INDICES.die)
  self.die_sprite:add()

  self.shadow_sprite = playdate.graphics.sprite.new()
  self.shadow_sprite:setZIndex(Z_INDICES.die_shadow)
  self.shadow_sprite:add()

  self.highlighting = Progress(HIGHLIGHT_ANIMATION_DURATION)
  self.highlighting:backward()

  self:randomize()
end

function Die:randomize()
  self.value = math.random(6)
  stat:add_die(self.value)
end

function Die:roll()
  self.roll_animation:reset()
end

function Die:play_shake_effect()
  local offset = math.random() * 0.05
  local volume = 0.6 + math.random() * 0.4
  local rate   = 0.8 + math.random() * 0.4

  shake_effect:playAt(playdate.sound.getCurrentTime() + offset, volume, nil, rate)
end

---@param value die_value
---@param size integer
---@param angle integer
---@return pd_image die, pd_image shadow
function Die.render(value, size, angle)
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
  end):rotatedImage(angle)

  local shadow = playdate.graphics.image.render(size, size, function()
    playdate.graphics.setColor(theme:foreground_color())
    playdate.graphics.setDitherPattern(0.5)
    playdate.graphics.fillRoundRect(0, 0, size, size, size / 5)
  end):rotatedImage(angle)

  return die, shadow
end

---@param value die_value
---@param angle integer
---@return pd_image die, pd_image shadow
function Die.prerendered(value, angle)
  local x = angle % 180 // 3 + 1
  
  local die = prerendered:getImage(x, value)
  local shadow = prerendered:getImage(x, 7)

  die:setInverted(not theme:is_dark_theme())
  shadow:setInverted(not theme:is_dark_theme())

  return die, shadow
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
  self.highlighting:update()

  if self:is_cache_invalidated() then
    local die_image, shadow_image = Die.prerendered(self.value, self.angle)
    self.die_sprite:setImage(die_image)
    self.shadow_sprite:setImage(shadow_image)
    self:save_cache()
  end
  
  local position = self.position
  
  if not self.roll_animation:ended() then
    local start_point = playdate.geometry.point.new(-self.size, -self.size)
    position = start_point:lerp(position, self.roll_animation:currentValue() --[[@as number]])
  end

  if not self.remove_animation:ended() then
    local finish_point = playdate.geometry.point.new(playdate.display.getWidth() + self.size, playdate.display.getHeight() + self.size)
    position = position:lerp(finish_point, self.remove_animation:currentValue() --[[@as number]])
  end
  
  local highlighting_offset = self.highlighting:progress() * HIGHLIGHT_HIGHT
  local floating_offset = self.highlighting:progress() * self.floating_animation:currentValue()
  local offset = highlighting_offset + floating_offset

  self.die_sprite:moveTo(
    math.floor(position.x),
    math.floor(position.y - offset)
  )

  self.shadow_sprite:moveTo(
    math.floor(position.x + offset / 2),
    math.floor(position.y + offset)
  )
end

function Die:start_removing()
  self.remove_animation = playdate.graphics.animator.new(REMOVE_ANIMATION_DURATION, 0, 1, playdate.easingFunctions.inOutCirc)
end

---@return boolean
function Die:is_ready_to_remove()
  return self.remove_animation:ended()
end

function Die:is_animating()
  return not self.roll_animation:ended() or not self.remove_animation:ended()
end

function Die:highlight()
  self.highlighting:forward()
end

function Die:unhighlight()
  self.highlighting:backward()
end

function Die:remove()
  self.die_sprite:remove()
  self.shadow_sprite:remove()
end