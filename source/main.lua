import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/animator"
import "../deps/classic"

import "vector3d"
import "progress"
import "shaking"
import "die"

local background_pattern = playdate.graphics.image.new("images/patterns/forwardslash")
  or error("Failed to load images/patterns/forwardslash.png")

playdate.display.setRefreshRate(50.0)

---@type die[]
local dice = {}

---@param die die
---@return boolean
local function try_add_die(die)
  local attempts = 0
  repeat
    local overlaps = false

    die.position.x = math.random(DIE_SIZE, playdate.display.getWidth() - DIE_SIZE * 1.5)
    die.position.y = math.random(DIE_SIZE, playdate.display.getHeight() - DIE_SIZE * 1.5)

    for i = 1, #dice do
      if die:center():distanceToPoint(dice[i]:center()) < MIN_DICE_DISTANCE then
        overlaps = true
        break
      end
    end

    attempts += 1

    if attempts > 20 then
      return false
    end

  until not overlaps

  die:predraw()
  die.show_animation:reset()
  table.insert(dice, die)
  return true
end

local function shuffle_dice()
  local prev_dice = dice

  ::restart::
  dice = {}

  for i = 1, #prev_dice do
    if not try_add_die(prev_dice[i]) then
      goto restart
    end

    prev_dice[i]:roll()
  end
end

---@param die die
local function add_die(die)
  while not try_add_die(die) do
    shuffle_dice()
  end

  die:play_roll_effect()
end

local function remove_random_die()
  if #dice > 1 then
    table.remove(dice, math.random(#dice))
  end
end

add_die(die())
add_die(die())
add_die(die())

local fade = progress(10)

function playdate.update()
  shaking:update()
  fade:update()

  if shaking.is_shaking and shaking.is_extremum then
    for i = 1, #dice do
      dice[i]:play_shake_effect()
    end
  end

  if shaking.is_stop_shaking then
    shuffle_dice()

    for i = 1, #dice do
      dice[i]:play_roll_effect()
    end
  end

  if playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonUp) then
    if (#dice < 6) then
      add_die(die())
    end
  end

  if playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonDown) then
    remove_random_die()
  end

  if shaking.is_shaking then
    fade:forward()
  else
    fade:backward()
  end

  playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.clear()

  playdate.graphics.pushContext()
  playdate.graphics.setPattern(background_pattern)
  playdate.graphics.fillRoundRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight(), 15)
  playdate.graphics.popContext()

  for i = 1, #dice do
    dice[i]:draw()
  end

  playdate.graphics.fillCircleAtPoint(
    playdate.display.getWidth() / 2,
    playdate.display.getHeight() / 2,
    fade:progress() * 400,
    playdate.graphics.kColorBlack
  )
end