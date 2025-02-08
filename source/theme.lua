---@alias theme_values { bg: pd_color, fg: pd_color, bg_pattern: pd_image }

---@type theme_values
local dark_theme = {
  bg = playdate.graphics.kColorBlack,
  fg = playdate.graphics.kColorWhite,
  bg_pattern = playdate.graphics.image.new("images/patterns/forwardslash_dark")
    or error("Failed to load images/patterns/forwardslash_dark"),
}

---@type theme_values
local light_theme = {
  bg = playdate.graphics.kColorWhite,
  fg = playdate.graphics.kColorBlack,
  bg_pattern = playdate.graphics.image.new("images/patterns/forwardslash_light")
    or error("Failed to load images/patterns/forwardslash_light"),
}

---@class theme
---@field values theme_values
---@field version number
theme = { values = dark_theme, version = 0 }

---@param new_theme "dark" | "light"
function theme:set(new_theme)
  if new_theme == "dark" then
    self.values = dark_theme
  else
    self.values = light_theme
  end

  self.version += 1
end

function theme:toggle()
  if self.values == dark_theme then
    self.values = light_theme
  else
    self.values = dark_theme
  end
  
  self.version += 1
end

function theme:background_color()
  return self.values.bg
end

function theme:foreground_color()
  return self.values.fg
end

function theme:background_pattern()
  return self.values.bg_pattern
end

function theme:text_draw_mode()
  if self.values.fg == playdate.graphics.kColorBlack then
    return playdate.graphics.kDrawModeFillBlack
  else
    return playdate.graphics.kDrawModeFillWhite
  end
end