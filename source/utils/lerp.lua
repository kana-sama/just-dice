---@class pd_point
---@field lerp fun(self: pd_point, target: pd_point, t: number): pd_point

function playdate.geometry.point:lerp(target, t)
  return playdate.geometry.point.new(
    self.x + (target.x - self.x) * t,
    self.y + (target.y - self.y) * t
  )
end