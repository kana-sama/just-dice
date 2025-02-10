local cursor_image = playdate.graphics.image.new("assets/images/cursor")
    or error("Failed to load 'assets/images/cursor.png'")

local _, CURSOR_HEIGHT <const> = cursor_image:getSize()
local FLOATING_OFFSET <const> = 5

---@param target pd_rect
---@return number x, number y, number angle
local function position_for_target(target)
  local x, y, w, h = target:unpack()

  local cursor_x = x + w / 2
  local cursor_y = y - CURSOR_HEIGHT / 2 - FLOATING_OFFSET
  local angle = 0

  if cursor_y < CURSOR_HEIGHT then
    cursor_y = y + h + CURSOR_HEIGHT / 2 + FLOATING_OFFSET
    angle = 180
  end

  return cursor_x, cursor_y, angle
end

---@class Cursor
---@overload fun(target: pd_rect): Cursor
Cursor = Object:extend()

---@param target pd_rect
function Cursor:new(target)
  self.sprite = playdate.graphics.sprite.new(cursor_image)
  self.sprite:setZIndex(Z_INDICES.cursor)
  self.sprite:add()

  self.animation = playdate.graphics.animator.new(700, -FLOATING_OFFSET/2, FLOATING_OFFSET/2, playdate.easingFunctions.inOutCirc)
  self.animation.reverses = true
  self.animation.repeatCount = -1

  local cursor_x, cursor_y, angle = position_for_target(target)
  self.x = Smooth(cursor_x)
  self.y = Smooth(cursor_y)
  self.angle = angle
end

---@param target pd_rect
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
