DIE_SIZE = 50
DIE_POINT_RADIUS = 4
MIN_DICE_DISTANCE = DIE_SIZE * 1.42

local roll_effect = playdate.sound.sample.new("audio/roll")
  or error("Failed to load audio/roll.wav")

local shake_effect = playdate.sound.sample.new("audio/shake")
  or error("Failed to load audio/shake.wav")

---@class die
---@field value 1 | 2 | 3 | 4 | 5 | 6
---@field position pd_point
---@field angle number
---@field image pd_image
---@field show_animation pd_animator
---@overload fun(): die
die = Object:extend()

function die:new()
  self.value = math.random(6)
  self.position = playdate.geometry.point.new(0, 0)
  self.angle = math.random(360)
  self.image = playdate.graphics.image.new(DIE_SIZE, DIE_SIZE)
  self.show_animation = playdate.graphics.animator.new(500, 0, 1, playdate.easingFunctions.outCirc)
end

function die:roll()
  self.value = math.random(6)
end

---@return pd_point
function die:center()
  return self.position + playdate.geometry.vector2D.new(DIE_SIZE / 2, DIE_SIZE / 2)
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

function die:predraw()
  local image = playdate.graphics.image.new(DIE_SIZE, DIE_SIZE)

  playdate.graphics.pushContext(image)

  playdate.graphics.fillRoundRect(0, 0, DIE_SIZE, DIE_SIZE, 15)

  playdate.graphics.setLineWidth(DIE_POINT_RADIUS)
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  if self.value == 1 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, DIE_POINT_RADIUS)
  elseif self.value == 2 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
  elseif self.value == 3 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
  elseif self.value == 4 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
  elseif self.value == 5 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 2, DIE_SIZE / 2, DIE_POINT_RADIUS)
  elseif self.value == 6 then
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 4 * 3, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4, DIE_SIZE / 2, DIE_POINT_RADIUS)
    playdate.graphics.drawCircleAtPoint(DIE_SIZE / 4 * 3, DIE_SIZE / 2, DIE_POINT_RADIUS)
  end

  playdate.graphics.popContext()

  self.image = image:rotatedImage(self.angle)
end

function die:draw()
  self.image:draw(
    self.position.x * self.show_animation:currentValue(),
    self.position.y * self.show_animation:currentValue()
  )
end