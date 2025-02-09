local INITIAL_DICE_COUNT <const> = 3
local MAX_DICE_COUNT <const> = 6

local find_free_place_for_die

---@class Game
---@overload fun(): Game
Game = Object:extend()

function Game:new()
  ---@type Die[]
  self.dice = {}

  ---@type Die[]
  self.random_task_list = {}

  self.die_size = DIE_SIZES[INITIAL_DICE_COUNT]

  self.background = Background()
  self.fade = Fade()
  self.lock = Lock()
  self.shaking = Shaking()

  for _ = 1, INITIAL_DICE_COUNT do
    local die = Die(self.die_size)
    self:add_dice({ die })
    die:roll()
  end
end

function Game:set_dice_size(size)
  for _, die in ipairs(self.dice) do
    die.size = size
  end
end

---@param new_dice Die[]
---@return Die[] moved_dice
function Game:add_dice(new_dice)
  ---@type pd_point[]
  local positions = {}

  for i, die in ipairs(self.dice) do
    positions[i] = die.position
  end

  for _, new_die in ipairs(new_dice) do
    table.insert(self.dice, new_die)
  end

  while #positions < #self.dice do
    local position = find_free_place_for_die(self.die_size, positions)
    if position then
      table.insert(positions, position)
    else
      positions = {}
    end
  end

  ---@type Die[]
  local moved_dice = {}

  for i, die in ipairs(self.dice) do
    if die.position ~= positions[i] then
      die.position = positions[i]
      table.insert(moved_dice, die)
    end
  end

  return moved_dice
end

function Game:reroll_dice()
  local dice = self.dice
  self.dice = {}
  self:add_dice(dice)
  
  for _, die in ipairs(self.dice) do
    die:roll()
  end
end

function Game:remove_random_die()
  ---@type Die
  local die = table.remove(self.dice, math.random(#self.dice))

  die:remove()
end

function Game:update()
  self.shaking:update()
  self.fade:update()
  self.lock:update()
  self.background:update()

  if self.lock:is_unlocked() then
    if self.shaking.is_start_shaking then
      self.random_task_list = {}
      table.shallowcopy(self.dice, self.random_task_list)
    end

    if self.shaking.is_shaking and self.fade:is_faded() and #self.random_task_list > 0 then
      ---@type Die
      local die = table.remove(self.random_task_list)
      die:randomize()
    end

    if self.shaking.is_shaking and self.shaking.is_extremum then
      for _, die in ipairs(self.dice) do
        die:play_shake_effect()
      end
    end

    if self.shaking.is_stop_shaking then
      while #self.random_task_list > 0 do
        table.remove(self.random_task_list):roll()
      end

      self:reroll_dice()
    end

    if playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonUp) then
      if #self.dice < MAX_DICE_COUNT then
        self.die_size = DIE_SIZES[#self.dice + 1]
        
        local moved_die = self:add_dice({ Die() })
        for _, die in ipairs(moved_die) do
          die:roll()
        end
      end
    end

    if playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonDown) then
      if #self.dice > 1 then
        self.die_size = DIE_SIZES[#self.dice - 1]
        
        self:remove_random_die()
        self:reroll_dice()
      end
    end
  end

  self.fade:set(self.lock:is_unlocked() and self.shaking.is_shaking)

  self.die_size = DIE_SIZES[#self.dice]
  for _, die in ipairs(self.dice) do
    die.size = self.die_size
    die:update()
  end
end

---@param die_size number
---@param other pd_point[]
---@return pd_point?
function find_free_place_for_die(die_size, other)
  local position = playdate.geometry.point.new(0, 0)
  local attempts = 0
  repeat
    if attempts > 20 then
      return nil
    end

    local overlaps = false

    position.x = math.random(die_size, math.floor(playdate.display.getWidth() - die_size * 1.5))
    position.y = math.random(die_size, math.floor(playdate.display.getHeight() - die_size * 1.5))

    for _, other_position in ipairs(other) do
      if other_position:distanceToPoint(position) < die_size * 1.41 then
        overlaps = true
        break
      end
    end

    attempts += 1
  until not overlaps

  return position
end
