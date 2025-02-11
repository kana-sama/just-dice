local INITIAL_DICE_COUNT <const> = 9
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
  self.random_task_queue = {}

  ---@type table<integer, boolean>
  self.selected = {}
  self.active_die = 1

  ---@type { weak_ref: Die? }
  self.prev_active_die = { weak_ref = nil }
  setmetatable(self.prev_active_die, {__mode = "v"})

  ---@type Cursor?
  self.cursor = nil

  self.screen_shaking = 0
  
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
  if not die then
    print("Game:remove_die was called with wrong index " .. index)
    return
  end

  table.insert(self.remove_task_list, die)
  die:start_removing()

  local positions = {}
  for i, die in ipairs(self.dice) do
    positions[i] = die.position
  end

  if not is_valid_positions(DIE_SIZES[#self.dice], positions) then
    self:roll_all_dice()
  end
end

---@param dice_indices_to_reroll integer[]
function Game:roll_dice_by_indices(dice_indices_to_reroll)
  ---@type Die[]
  local dice_to_reroll = {}
  table.sort(dice_indices_to_reroll, function(a, b) return a > b end)
  for _, die_index in ipairs(dice_indices_to_reroll) do
    local die = table.remove_elem(self.dice, die_index)
    table.insert(dice_to_reroll, die)
  end  

  self:add_dice(dice_to_reroll)
  for _, die in ipairs(dice_to_reroll) do
    die:roll()
  end
end

function Game:roll_all_dice()
  local dice_indices_to_reroll = {}

  for i, _ in ipairs(self.dice) do
    table.insert(dice_indices_to_reroll, i)
  end

  self:roll_dice_by_indices(dice_indices_to_reroll)
end

function Game:play_selected_dice_shake_effect()
  local is_something_selected = self:is_something_selected()

  for i, die in ipairs(self.dice) do
    if not is_something_selected or is_something_selected and self.selected[i] then
      die:play_shake_effect()
    end
  end
end

function Game:play_all_dice_shake_effect()
  for _, die in ipairs(self.dice) do
    die:play_shake_effect()
  end
end

function Game:roll_selected_dice()
  local dice_indices_to_reroll = {}

  for i, _ in ipairs(self.dice) do
    if self.selected[i] then
      table.insert(dice_indices_to_reroll, i)
    end
  end

  self:roll_dice_by_indices(dice_indices_to_reroll)
end

function Game:logic()
  if self.shaking.is_start_shaking then
    self:stop_selection()
    
    if self:is_something_selected() then
      self:move_selected_to_random_task_list()
    else
      self:move_all_to_random_task_list()
    end
  end

  if self.shaking.is_shaking and self.fade:is_faded_in() and #self.random_task_queue > 0 then
    local die = table.remove_elem(self.random_task_queue, #self.random_task_queue)
    die:randomize()
  end

  if self.shaking.is_shaking and self.shaking.is_extremum then
    if self:is_something_selected() then
      self:play_selected_dice_shake_effect()
    else
      self:play_all_dice_shake_effect()
    end
  end

  if self.shaking.is_stop_shaking then
    while #self.random_task_queue > 0 do
      table.remove(self.random_task_queue):roll()
    end

    if self:is_something_selected() then
      self:roll_selected_dice()
    else
      self:roll_all_dice()
    end

    self:clear_selection()
  end

  if self.cursor then
    if input.left or input.down then self:move_cursor_left() end
    if input.right or input.up then self:move_cursor_right() end
    if input.a then self:toggle_active_die() end
    if input.b then self:cancel_selection() end
  else
    if input.left or input.down then
      if #self.dice > 1 then
        self:remove_die(math.random(#self.dice))
      end
    end

    if input.right or input.up then
      if #self.dice < MAX_DICE_COUNT then
        local moved_die = self:add_dice({ Die(self.die_size) })
        for _, die in ipairs(moved_die) do
          die:roll()
        end
      end
    end

    if input.a then
      if self:all_animations_ended() then
        self:start_selection()
      else
        self:shake_screen()
      end
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

sample("Die:update", function()
  for i, die in ipairs(self.dice) do
    die.size = self.die_size

    if self.selected[i] then
      die:highlight()
    else
      die:unhighlight()
    end

    die:update()
  end
end)

  for i, die in ipairs(self.remove_task_list) do
    die.size = self.die_size
    die:update()

    if die:is_ready_to_remove() then
      die:remove()
      table.remove_elem(self.remove_task_list, i)
    end
  end

  if self.cursor then
    self.cursor:move_to(self.dice[self.active_die].die_sprite:getBoundsRect())
    self.cursor:update()
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

---@return boolean
function Game:is_something_selected()
  for i, _ in ipairs(self.dice) do
    if self.selected[i] then
      return true
    end
  end

  return false
end

function Game:move_all_to_random_task_list()
  self.random_task_queue = {}
  self.random_task_queue = table.shallowcopy(self.dice)
end

function Game:move_selected_to_random_task_list()
  self.random_task_queue = {}
  for i, die in ipairs(self.dice) do
    if self.selected[i] then
      table.insert(self.random_task_queue, die)
    end
  end
end

function Game:start_selection()
  UISound:start_selection()

  self.active_die = 1

  if self.prev_active_die.weak_ref then
    for i, die in ipairs(self.dice) do
      if die == self.prev_active_die.weak_ref then
        self.active_die = i
        break
      end
    end
  end

  if self.active_die > #self.dice then
    self.active_die = 1
  end

  self.cursor = Cursor(self.dice[self.active_die].die_sprite:getBoundsRect())
  self.selected = {}
end

function Game:cancel_selection()
  UISound:cancel_selection()
  self:clear_selection()
  self:stop_selection()
end

function Game:stop_selection()
  if self.cursor then
    self.prev_active_die.weak_ref = self.dice[self.active_die]
    self.cursor:remove()
    self.cursor = nil
  end
end

function Game:clear_selection()
  self.selected = {}
end


function Game:move_cursor_left()
  UISound:move_cursor()
  self.active_die -= 1
  if self.active_die < 1 then
    self.active_die = #self.dice
  end
end

function Game:move_cursor_right()
  UISound:move_cursor()
  self.active_die += 1
  if self.active_die > #self.dice then
    self.active_die = 1
  end
end

function Game:toggle_active_die()
  self.selected[self.active_die] = not self.selected[self.active_die]

  if self.selected[self.active_die] then
    UISound:activate_die()
  else
    UISound:deactivate_die()
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
