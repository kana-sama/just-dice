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

  self.screen_shaking = 0

  self.last_selected_die = 1

  self.die_size = DIE_SIZES[INITIAL_DICE_COUNT]

  self.background = Background()
  self.fade = Fade()
  self.lock = Lock()
  self.shaking = Shaking()

  self.logic_co = coroutine.forever(function() self:logic() end)

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

  table.sort(self.dice, function(a, b)
    return a.position.x < b.position.x
  end)

  return moved_dice
end

---@param index integer
function Game:remove_die(index)
  local die = table.remove_elem(self.dice, index)
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

---@param die_index integer
function Game:reroll_die(die_index)
  self:remove_die(die_index)

  local die = Die(self.die_size)
  self:add_dice({ die })
  die:roll()
end

function Game:reroll_dice()
  local dice = self.dice
  self.dice = {}
  self:add_dice(dice)
  
  for _, die in ipairs(self.dice) do
    die:roll()
  end
end

function Game:logic()
  if self.shaking.is_start_shaking then
    self.random_task_list = {}
    table.shallowcopy(self.dice, self.random_task_list)
  end

  if self.shaking.is_shaking and self.fade:is_faded_in() and #self.random_task_list > 0 then
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

  if input.right or input.up then
    if #self.dice < MAX_DICE_COUNT then
      local moved_die = self:add_dice({ Die(self.die_size) })
      for _, die in ipairs(moved_die) do
        die:roll()
      end
    end
  end

  if input.left or input.down then
    if #self.dice > 1 then
      self:remove_die(math.random(#self.dice))
    end
  end

  if input.a then
    if self:all_animations_ended() then
      local _, die_index = self:select_die()

      if die_index then
        self:reroll_die(die_index)
      end
    else
      self:shake_screen()
    end
  end
end

function Game:update()
  self.shaking:update()
  self.fade:update()
  self.lock:update()
  self.background:update()

  if self.lock:is_unlocked() then
    local ok, err = coroutine.resume(self.logic_co)
    if not ok then error(err) end
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

  if self.screen_shaking > 0 then
    playdate.display.setOffset(math.random(-2, 2), math.random(-2, 2))
    self.screen_shaking -= 1
  else
    playdate.display.setOffset(0, 0)
  end
end

function Game:all_animations_ended()
  if not self.fade:is_faded_out() then
    return false
  end

  if #self.remove_task_list > 0 then
    return false
  end

  for _, die in ipairs(self.dice) do
    if die:is_animating() then
      return false
    end
  end

  return true
end

function Game:shake_screen()
  self.screen_shaking = 10
end

---@return Die? die, integer? die_index
function Game:select_die()
  ---@type number?
  local selected

  if self.last_selected_die > #self.dice then
    selected = 1
  else
    selected = self.last_selected_die
  end

  local cursor = Cursor(self.dice[selected].die_sprite)

  while true do
    coroutine.yield()
    cursor:update()

    for _, die in ipairs(self.dice) do
      die:update()
    end

    if input.left then
      selected -= 1
      
      if selected < 1 then
        selected = #self.dice
      end
    end

    if input.right then
      selected += 1

      if selected > #self.dice then
        selected = 1
      end
    end

    if input.a then
      break
    end

    if input.b then
      selected = nil
      break
    end

    cursor:move_to(self.dice[selected].die_sprite)

    for i, die in ipairs(self.dice) do
      if i == selected then
        die:highlight()
      else
        die:unhighlight()
      end
    end
  end

  cursor:remove()

  for _, die in ipairs(self.dice) do
    die:unhighlight()
  end

  if selected then
    self.last_selected_die = selected
    return self.dice[selected], selected
  else
    return nil
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
