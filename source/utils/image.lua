---@class pd_image_lib
playdate.graphics.image = playdate.graphics.image

---@param width number
---@param height number
---@param draw fun()
---@return pd_image
function playdate.graphics.image.render(width, height, draw)
  local image = playdate.graphics.image.new(width, height)
  playdate.graphics.pushContext(image)
  draw()
  playdate.graphics.popContext()
  return image
end