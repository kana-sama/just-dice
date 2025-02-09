local stat_font = playdate.graphics.font.new("assets/fonts/Roobert-11-Mono-Condensed")
    or error("Failed to load font 'assets/fonts/Roobert-11-Mono-Condensed.fnt'")

local shorten

---@class stat
---@field rolls table<die_value, integer>
stat = {
  rolls = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  }
}

---@param value die_value
function stat:add_die(value)
  self.rolls[value] = self.rolls[value] + 1
end

---@return integer
function stat:total()
  local total = 0
  for _, value in pairs(self.rolls) do
    total = total + value
  end
  return total
end

---@return pd_image
function stat:render()
  local LINE_SIZE <const> = 35
  local START_Y = 25

  local image = playdate.graphics.image.new(400, 240)

  playdate.graphics.pushContext(image)

  playdate.graphics.setColor(theme:background_color())
  playdate.graphics.setDitherPattern(0.05)
  playdate.graphics.fillRect(0, 0, 400, 240)

  playdate.graphics.setFont(stat_font)
  for i = 1, 6 do
    local line_y = START_Y + LINE_SIZE * (i - 1)
    local rolls = shorten(self.rolls[i])
    local perc = string.format("%.f%%", rolls / self:total() * 100)

    Die.render(i, 20):draw(30, line_y)

    playdate.graphics.pushContext()
    playdate.graphics.setImageDrawMode(theme:text_draw_mode())
    playdate.graphics.drawText(rolls, 75, line_y + 4, 50, 20, playdate.graphics.kAlignCenter)
    playdate.graphics.drawText(perc, 140, line_y + 4, 30, 20, playdate.graphics.kAlignRight)
    playdate.graphics.popContext()

    if i < 6 then
      playdate.graphics.setColor(theme:foreground_color())
      playdate.graphics.fillRect(20, line_y + LINE_SIZE - 8, 160, 1)
    end
  end

  playdate.graphics.popContext()

  return image
end


---@param value integer
---@return string
function shorten(value)
  if value < 1000 then
    return tostring(value)
  elseif value < 1000000 then
    return string.format("%.fk", value / 1000)
  elseif value < 1000000000 then
    return string.format("%.fm", value / 1000000)
  else
    return "..."
  end
end
