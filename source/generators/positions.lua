local MARGIN = 8
local REQUIRED_POSITIONS = 100

---@return pd_polygon, pd_polygon, integer center_x, integer center_y, integer angle
function generate_random_die()
  local box = playdate.geometry.rect.new(0, 0, DIE_SIZE, DIE_SIZE)

  local center_x = math.random(0, 400)
  local center_y = math.random(0, 240)
  local angle = math.random(0, 357 / 3) * 3

  local die = box:toPolygon() * playdate.geometry.affineTransform.new()
    :rotatedBy(angle, DIE_SIZE/2, DIE_SIZE/2)
    :translatedBy(-DIE_SIZE/2, -DIE_SIZE/2)
    :translatedBy(center_x, center_y)

  local outer = box:insetBy(-MARGIN/2, -MARGIN/2):toPolygon() * playdate.geometry.affineTransform.new()
    :rotatedBy(angle, DIE_SIZE/2, DIE_SIZE/2)
    :translatedBy(-DIE_SIZE/2, -DIE_SIZE/2)
    :translatedBy(center_x, center_y)

  return die, outer, center_x, center_y, angle
end

---@type {p:pd_polygon, o: pd_polygon, x:number, y:number,a:number}[]
local draft_positions = {}

---@param p pd_polygon
---@param cx number
---@param cy number
---@return boolean
function validate_new_polygon(p, cx, cy)
  local bx, by, bw, bh = p:getBounds()
  if bx < 10 or by < 10 or bx + bw > 390 or by + bh > 230 then
    return false
  end

  for _, r in ipairs(draft_positions) do
    if cx == r.x or cy == r.y then
      return false
    end

    if p:intersects(r.o) then
      return false
    end
  end

  return true
end

---@alias random_positions_table {x: integer, y: integer, angle: integer}[][]

---@type random_positions_table
local random_positions_table = {}

---@diagnostic disable-next-line: duplicate-set-field
function playdate.update()
  local to_reset = 10
  local attemps = 0
  while #draft_positions < MAX_DICE_COUNT do
    local p, o, x, y, a = generate_random_die()
    if validate_new_polygon(o, x, y) then
      table.insert(draft_positions, { p = p, o = o, x = x, y = y, a = a })
    end
    attemps += 1
    if attemps > 100 then
      attemps = 0
      to_reset -= 1

      if to_reset == 0 then
        to_reset = 10
        draft_positions = {}
      end

      coroutine.yield()
    end
  end

  playdate.graphics.clear()

  for _, r in ipairs(draft_positions) do
    playdate.graphics.fillPolygon(r.p)
    playdate.graphics.drawPolygon(r.o)
  end

  local positions = {}
  for _, r in ipairs(draft_positions) do
    table.insert(positions, { x = r.x, y = r.y, angle = r.a })
  end
  table.insert(random_positions_table, positions)
  draft_positions = {}

  print(#random_positions_table .. " / " .. REQUIRED_POSITIONS)

  if #random_positions_table == REQUIRED_POSITIONS then
    json.encodeToFile(playdate.file.open("positions.json", playdate.file.kFileWrite), true, random_positions_table)
    print("Done")
    error("")
  end
end

