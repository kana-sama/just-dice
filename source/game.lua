local INITIAL_DICE_COUNT <const> = 3
local MAX_DICE_COUNT <const> = 6

local find_free_place_for_die, is_valid_positions

---@class Game
---@overload fun(): Game
Game = Object:extend()

function Game:new()
  ---@type Die[]
  self.dice = {}

  ---@type Die[]
  self.remove_task_list = {}

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
    local position = find_free_place_for_die(DIE_SIZES[#self.dice], positions)
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

function Game:remove_die()
  local die = table.remove_elem(self.dice, math.random(#self.dice))
  table.insert(self.remove_task_list, die)
  die:start_removing()

  local positions = {}
  for i, die in ipairs(self.dice) do
    positions[i] = die.position
  end

  if not is_valid_positions(DIE_SIZES[#self.dice], positions) then
    self:reroll_dice()
  end
end

function Game:reroll_dice()
  local dice = self.dice
  self.dice = {}
  self:add_dice(dice)
  
  for _, die in ipairs(self.dice) do
    die:roll()
  end
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
      local die = table.remove_elem(self.random_task_list, 1)
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
        local moved_die = self:add_dice({ Die(self.die_size) })
        for _, die in ipairs(moved_die) do
          die:roll()
        end
      end
    end

    if playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonDown) then
      if #self.dice > 1 then
        self:remove_die()
      end
    end
  end

  self.fade:set(self.lock:is_unlocked() and self.shaking.is_shaking)

  self.die_size = DIE_SIZES[#self.dice]

  for _, die in ipairs(self.dice) do
    die.size = self.die_size
    die:update()
  end

  for i, die in ipairs(self.remove_task_list) do
    die.size = self.die_size
    die:update()

    if die:is_ready_to_remove() then
      die:remove()
      table.remove_elem(self.remove_task_list, i)
    end
  end
end

---@param size number
---@param positions pd_point[]
---@return boolean
function is_valid_positions(size, positions)
  for _, positions in ipairs(positions) do
    if positions.x < size * 0.7 or positions.x > playdate.display.getWidth() - size * 0.7 then
      return false
    end

    if positions.y < size * 0.7 or positions.y > playdate.display.getHeight() - size * 0.7 then
      return false
    end

    for _, other_position in ipairs(positions) do
      if other_position:distanceToPoint(positions) < size * 1.41 then
        return false
      end
    end
  end

  return true
end

---@param size number
---@param positions pd_point[]
---@return pd_point?
function find_free_place_for_die(size, positions)
  local position = playdate.geometry.point.new(0, 0)
  local attempts = 0

  repeat
    if attempts > 20 then
      return nil
    end

    local overlaps = false

    position.x = math.random(size * 0.7, math.floor(playdate.display.getWidth() - size * 0.7))
    position.y = math.random(size * 0.7, math.floor(playdate.display.getHeight() - size * 0.7))

    for _, other_position in ipairs(positions) do
      if other_position:distanceToPoint(position) < size * 1.41 then
        overlaps = true
        break
      end
    end

    attempts += 1
  until not overlaps

  return position
end
