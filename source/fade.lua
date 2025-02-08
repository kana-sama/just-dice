---@class fade : progress
fade = progress(10)

function fade:draw()
  playdate.graphics.setColor(theme:foreground_color())
  playdate.graphics.fillCircleAtPoint(
    playdate.display.getWidth() / 2,
    playdate.display.getHeight() / 2,
    fade:progress() * 400
  )
end