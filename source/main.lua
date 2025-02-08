import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/animator"

import "../deps/classic"

import "vector3d"
import "theme"
import "progress"
import "shaking"
import "die"
import "lock"
import "fade"
import "stat"

local INITIAL_DICE_COUNT <const> = 3
local MAX_DICE_COUNT <const> = 6

playdate.display.setRefreshRate(50.0)

playdate.getSystemMenu():addOptionsMenuItem("Theme", {"dark", "light"}, "dark", function(new_theme)
  theme:set(new_theme)
end)

function playdate.gameWillPause()
  playdate.setMenuImage(stat:render())
end

---@type die[]
local dice = {}

---@param other pd_point[]
---@return pd_point?
function find_free_place_for_die(other)
  local position = playdate.geometry.point.new(0, 0)
  local attempts = 0
  repeat
    local overlaps = false

    position.x = math.random(die.size, math.floor(playdate.display.getWidth() - die.size * 1.5))
    position.y = math.random(die.size, math.floor(playdate.display.getHeight() - die.size * 1.5))

    for i = 1, #other do
      if other[i]:distanceToPoint(position) < die.size * 1.41 then
        overlaps = true
        break
      end
    end

    attempts += 1

    if attempts > 20 then
      return nil
    end

  until not overlaps

  return position
end

---@param new_dice die[]
local function add_dice(new_dice)
  ---@type pd_point[]
  local positions = {}
  for i = 1, #dice do
    table.insert(positions, dice[i].position)
  end

  while #positions < #dice + #new_dice do
    local position = find_free_place_for_die(positions)
    if position then
      table.insert(positions, position)
    else
      positions = {}
    end
  end

  for i = 1, #new_dice do
    table.insert(dice, new_dice[i])
  end

  for i = 1, #positions do
    if dice[i].position ~= positions[i] then
      dice[i].position = positions[i]
      dice[i]:roll()
    end
  end
end

local function reroll_dice()
  local prev_dice = dice
  dice = {}
  add_dice(prev_dice)
end

local function remove_random_die()
  table.remove(dice, math.random(#dice))
end

---@param size number
local function set_dice_size(size)
  if size <= 2 then
    die.size = 70
  elseif size <= 4 then
    die.size = 60
  else
    die.size = 50
  end
end

set_dice_size(INITIAL_DICE_COUNT)
for _ = 1, INITIAL_DICE_COUNT do
  add_dice({die()})
end

function playdate.update()
  shaking:update()
  fade:update()
  lock:update()

  if lock.is_unlocked then
    if shaking.is_shaking and shaking.is_extremum then
      for i = 1, #dice do
        dice[i]:play_shake_effect()
      end
    end

    if shaking.is_stop_shaking then
      reroll_dice()

      for i = 1, #dice do
        dice[i]:play_roll_effect()
      end
    end

    if playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonUp) then
      if #dice < MAX_DICE_COUNT then
        set_dice_size(#dice + 1)
        add_dice({die()})
      end
    end

    if playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonDown) then
      if #dice > 1 then
        set_dice_size(#dice - 1)
        remove_random_die()
        reroll_dice()
      end
    end
  end

  if lock.is_unlocked and shaking.is_shaking then
    fade:forward()
  else
    fade:backward()
  end

  playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
  playdate.graphics.clear()
  playdate.graphics.setPattern(theme:background_pattern())
  playdate.graphics.fillRoundRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight(), 15)

  for i = 1, #dice do
    dice[i]:draw()
  end

  lock:draw()
  fade:draw()
end
