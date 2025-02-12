---@type random_positions_table
local random_positions_table =
    json.decodeFile(playdate.file.open("assets/positions.json", playdate.file.kFileRead))


---@class Game
---@overload fun(): Game
Game = Object:extend()

function Game:new()
  ---@type Die[]
  self.dice = {}

  ---@type Die[]
  self.removed_dice = {}

  ---@type table<Die, boolean>
  self.locked_dice = {}
  setmetatable(self.locked_dice, { __mode = "k" })

  ---@type { weak_ref: Die? }
  self.die_under_cursor = { weak_ref = nil }
  setmetatable(self.die_under_cursor, { __mode = "v" })

  ---@type Cursor?
  self.cursor = nil

  self.screen_shaking = 0

  self.background = Background()
  self.fade = Fade()
  self.lock = Lock()
  self.shaking = Shaking()

  self.logic_co = coroutine.forever(function() self:logic() end)

  for _ = 1, INITIAL_DICE_COUNT do
    table.insert(self.dice, Die(DIE_SIZE))
  end

  self:shuffle()
end

function Game:logic()
  if self.shaking.is_just_started then
    self.fade:set(true)

    if not self:is_something_locked() then
      self:remove_cursor()
    end
  end

  if self.shaking.is_going_on and self.shaking.is_on_extremum then
    self:play_dice_shake_effect()
  end

  if self.shaking.is_just_stopped then
    self:randomize()
    self:shuffle()
    self.fade:set(false)
  end

  if self.cursor then
    if input.left then
      self:move_cursor_left()
    end

    if input.right then
      self:move_cursor_right()
    end

    if input.up then
      self:move_cursor_up()
    end

    if input.down then
      self:move_cursor_down()
    end

    if input.a then
      self:toggle_active_die()
    end

    if input.b then
      self:unlock_all()
    end
  else
    if input.left then
      self:remove_die()
    end

    if input.right then
      self:add_die()
    end

    if input.a then
      self:add_cursor()
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

  for _, die in ipairs(self.dice) do
    if self.locked_dice[die] then
      die:highlight()
    else
      die:unhighlight()
    end

    die:update()
  end

  for i, die in ipairs(self.removed_dice) do
    die:update()

    if die:is_ready_to_remove() then
      die:remove()
      table.remove_elem(self.removed_dice, i)
    end
  end

  if self.cursor and self.die_under_cursor.weak_ref then
    self.cursor:move_to(self.die_under_cursor.weak_ref.die_sprite:getBoundsRect())
    self.cursor:update()
  end

  if self.screen_shaking > 0 then
    playdate.display.setOffset(math.random(-2, 2), math.random(-2, 2))
    self.screen_shaking -= 1
  else
    playdate.display.setOffset(0, 0)
  end
end


-- Rolling and shaking

function Game:add_die()
  if #self.dice < MAX_DICE_COUNT then
    local position_index = math.random(#self.dice + 1, MAX_DICE_COUNT)
    self.positions[#self.dice + 1], self.positions[position_index] = self.positions[position_index], self.positions[#self.dice + 1]
    table.insert(self.dice, Die(DIE_SIZE))
    self:apply_positions()
  else
    self:shake_screen()
  end
end

function Game:remove_die()
  if #self.dice > 1 then
    local die = table.remove_elem(self.dice, #self.dice)
    table.insert(self.removed_dice, die)
    die:start_removing()
  else
    self:shake_screen()
  end
end

function Game:apply_positions()
  for i, die in ipairs(self.dice) do
    local changed = false

    if die.position.x ~= self.positions[i].x then
      changed = true
      die.position.x = self.positions[i].x
    end

    if die.position.y ~= self.positions[i].y then
      changed = true
      die.position.y = self.positions[i].y
    end

    if die.angle ~= self.positions[i].angle then
      changed = true
      die.angle = self.positions[i].angle
    end

    if changed then
      die:roll()
    end
  end
end

function Game:randomize()
  for _, die in ipairs(self.dice) do
    if not self.locked_dice[die] then
      die:randomize()
    end
  end
end

function Game:shuffle()
  local old_positions = self.positions
  while old_positions == self.positions do
    self.positions = random_positions_table[math.random(#random_positions_table)]
  end
  
  self:apply_positions()
end

function Game:play_dice_shake_effect()
  local is_something_locked = self:is_something_locked()

  for _, die in ipairs(self.dice) do
    if not is_something_locked or is_something_locked and self.locked_dice[die] then
      die:play_shake_effect()
    end
  end
end


-- Locking

function Game:add_cursor()
  UISound:start_locking()

  if self.die_under_cursor.weak_ref then
    local found = false

    for _, die in ipairs(self.dice) do
      if die == self.die_under_cursor.weak_ref then
        found = true
        break
      end
    end

    if not found then
      self.die_under_cursor.weak_ref = nil
    end
  end
  
  if not self.die_under_cursor.weak_ref then
    self.die_under_cursor.weak_ref = self.dice[1]
  end
  
  for _, die in ipairs(self.dice) do
    self.locked_dice[die] = true
  end

  self.cursor = Cursor(self.die_under_cursor.weak_ref.die_sprite:getBoundsRect())
end

function Game:remove_cursor()
  UISound:cancel_locking()

  if self.cursor then
    self.cursor:remove()
    self.cursor = nil
  end
end

function Game:unlock_all()
  self:remove_cursor()
  self.locked_dice = {}
end

---@param distance fun(active: pd_point, other: pd_point): number
function Game:move_cursor_to_nearest(distance)
  ---@type { die: Die, distance: number }[]
  local dice_with_distances = {}

  ---@param die Die
  ---@param position pd_point
  function add_position(die, position)
    local distance = distance(self.die_under_cursor.weak_ref.position, position)
    
    if distance > 0 then
      table.insert(dice_with_distances, {
        die = die,
        distance = distance,
      })
    end
  end

  for _, die in ipairs(self.dice) do
    add_position(die, die.position)
    add_position(die, die.position:copy():offsetBy(playdate.display.getWidth(), 0))
    add_position(die, die.position:copy():offsetBy(-playdate.display.getWidth(), 0))
    add_position(die, die.position:copy():offsetBy(0, playdate.display.getHeight()))
    add_position(die, die.position:copy():offsetBy(0, -playdate.display.getHeight()))
  end

  table.sort(dice_with_distances, function(a, b)
    return a.distance < b.distance
  end)

  if #dice_with_distances > 0 then
    UISound:move_cursor()
    self.die_under_cursor.weak_ref = dice_with_distances[1].die
  else
    UISound:deactivate_die()
  end
end

function Game:move_cursor_left()
  self:move_cursor_to_nearest(function(active, other)
    return active.x - other.x
  end)
end

function Game:move_cursor_right()
  self:move_cursor_to_nearest(function(active, other)
    return other.x - active.x
  end)
end

function Game:move_cursor_up()
  self:move_cursor_to_nearest(function(active, other)
    return active.y - other.y
  end)
end

function Game:move_cursor_down()
  self:move_cursor_to_nearest(function(active, other)
    return other.y - active.y
  end)
end

function Game:toggle_active_die()
  self.locked_dice[self.die_under_cursor.weak_ref] = not self.locked_dice[self.die_under_cursor.weak_ref]

  if self.locked_dice[self.die_under_cursor.weak_ref] then
    UISound:activate_die()
  else
    UISound:deactivate_die()
  end
end

---@return boolean
function Game:is_something_locked()
  for _, die in ipairs(self.dice) do
    if self.locked_dice[die] then
      return true
    end
  end

  return false
end


-- Utility

function Game:shake_screen()
  self.screen_shaking = 10
end