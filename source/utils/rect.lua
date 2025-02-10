---@class pd_rect
playdate.geometry.rect = playdate.geometry.rect


---@return pd_rect
function playdate.geometry.rect:clone()
  return playdate.geometry.rect.new(self:unpack())
end