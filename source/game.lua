local INITIAL_DICE_COUNT <const> = 3
local MAX_DICE_COUNT <const> = 6

---@param other pd_point[]
---@return pd_point?
function find_free_place_for_die(other)
  local position = playdate.geometry.point.new(0, 0)
  local attempts = 0
  repeat
    local overlaps = false

    position.x = math.random(Die.size, math.floor(playdate.display.getWidth() - Die.size * 1.5))
    position.y = math.random(Die.size, math.floor(playdate.display.getHeight() - Die.size * 1.5))

    for i = 1, #other do
      if other[i]:distanceToPoint(position) < Die.size * 1.41 then
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

---@param size number
local function set_dice_size(size)
  if size <= 2 then
    Die.size = 70
  elseif size <= 4 then
    Die.size = 60
  else
    Die.size = 50
  end
end


---@class Game
---@overload fun(): Game
Game = Object:extend()

function Game:new()
  ---@type Die[]
  self.dice = {}

  self.background = Background()
  self.fade = Fade()
  self.lock = Lock()
  self.shaking = Shaking()

  set_dice_size(INITIAL_DICE_COUNT)
  for _ = 1, INITIAL_DICE_COUNT do
    self:add_dice({ Die() })
  end
end

---@param new_dice Die[]
function Game:add_dice(new_dice)
  ---@type pd_point[]
  local positions = {}
  for i = 1, #self.dice do
    table.insert(positions, self.dice[i].position)
  end

  while #positions < #self.dice + #new_dice do
    local position = find_free_place_for_die(positions)
    if position then
      table.insert(positions, position)
    else
      positions = {}
    end
  end

  for i = 1, #new_dice do
    table.insert(self.dice, new_dice[i])
  end

  for i = 1, #positions do
    if self.dice[i].position ~= positions[i] then
      self.dice[i].position = positions[i]
      self.dice[i]:roll()
    end
  end
end

function Game:reroll_dice()
  local prev_dice = self.dice
  self.dice = {}
  self:add_dice(prev_dice)
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
    if self.shaking.is_shaking and self.shaking.is_extremum then
      for i = 1, #self.dice do
        self.dice[i]:play_shake_effect()
      end
    end

    if self.shaking.is_stop_shaking then
      self:reroll_dice()
    end

    if playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonUp) then
      if #self.dice < MAX_DICE_COUNT then
        set_dice_size(#self.dice + 1)
        self:add_dice({ Die() })
      end
    end

    if playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonDown) then
      if #self.dice > 1 then
        set_dice_size(#self.dice - 1)
        self:remove_random_die()
        self:reroll_dice()
      end
    end
  end

  self.fade:set(self.lock:is_unlocked() and self.shaking.is_shaking)

  for i = 1, #self.dice do
    self.dice[i]:update()
  end
end
