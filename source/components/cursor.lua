local cursor_image = playdate.graphics.image.new("assets/images/cursor")
    or error("Failed to load 'assets/images/cursor.png'")

local _, CURSOR_HEIGHT <const> = cursor_image:getSize()
local CURSOR_OFFSET <const> = 5

local position_for_target

---@class Cursor
---@overload fun(target: pd_sprite): Cursor
Cursor = Object:extend()

---@param target pd_sprite
function Cursor:new(target)
  self.sprite = playdate.graphics.sprite.new(cursor_image)
  self.sprite:setZIndex(Z_INDICES.cursor)
  self.sprite:add()

  self.animation = playdate.graphics.animator.new(700, -CURSOR_OFFSET/2, CURSOR_OFFSET/2, playdate.easingFunctions.inOutCirc)
  self.animation.reverses = true
  self.animation.repeatCount = -1

  local cursor_x, cursor_y, angle = position_for_target(target)
  self.x = Smooth(cursor_x)
  self.y = Smooth(cursor_y)
  self.angle = angle
end

---@param target pd_sprite
function Cursor:move_to(target)
  local cursor_x, cursor_y, angle = position_for_target(target)
  self.x:set(cursor_x)
  self.y:set(cursor_y)
  self.angle = angle
end

function Cursor:update()
  self.x:update()
  self.y:update()

  self.sprite:setRotation(self.angle)
  self.sprite:moveTo(self.x:get(), self.y:get() + self.animation:currentValue())
  self.sprite:setImageDrawMode(theme:is_dark_theme() and playdate.graphics.kDrawModeCopy or playdate.graphics.kDrawModeInverted)
end

function Cursor:remove()
  self.sprite:remove()
end

---@param target pd_sprite
---@return number x, number y, number angle
function position_for_target(target)
  local x, y, w, h = target:getBoundsRect():unpack()

  local cursor_x = x + w / 2
  local cursor_y = y - CURSOR_HEIGHT / 2 - CURSOR_OFFSET
  local angle = 0

  if cursor_y < CURSOR_HEIGHT then
    cursor_y = y + h + CURSOR_HEIGHT / 2 + CURSOR_OFFSET
    angle = 180
  end

  return cursor_x, cursor_y, angle
end