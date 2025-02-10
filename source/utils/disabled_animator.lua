---@class pd_animator_lib
playdate.graphics.animator = playdate.graphics.animator

---@class DisabledAnimator: pd_animator
---@overload fun(startValue: number): DisabledAnimator
DisabledAnimator = Object:extend()

---@param startValue number
function DisabledAnimator:new(startValue)
  self.startValue = startValue
end

---@param startValue number
---@return pd_animator
function playdate.graphics.animator.disabled(startValue)
  return DisabledAnimator(startValue)
end

---@return number
function DisabledAnimator:progress()
  return 0
end

---@return number
function DisabledAnimator:currentValue()
  return self.startValue
end