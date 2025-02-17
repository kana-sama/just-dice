local image_width, image_height = 0, 0

for angle = 0, 359, 3 do
  local w, h = Die.render(1, DIE_SIZE, angle):getSize()
  image_width = math.max(image_width, w)
  image_height = math.max(image_height, h)
end

local set = playdate.graphics.image.new(image_width * 60, image_height * 7)
playdate.graphics.pushContext(set)

for angle = 0, 177, 3 do
  ---@type pd_image, pd_image
  local die, shadow

  for value = 1, 6 do
    die, shadow = Die.render(value, DIE_SIZE, angle)
    local w, h = die:getSize()
    die:draw((angle // 3) * image_width + (image_width - w) / 2, (value - 1) * image_height + (image_height - h) / 2)
  end

  local w, h = shadow:getSize()
  shadow:draw((angle // 3) * image_width + (image_width - w) / 2, 6 * image_height + (image_height - h) / 2)
end

playdate.graphics.popContext()
playdate.datastore.writeImage(set, "dice-table-" .. image_width .. "-" .. image_height .. ".gif")

error("done")
