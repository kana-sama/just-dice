---@class theme_values
---@field bg pd_color
---@field fg pd_color
---@field bg_pattern pd_image

---@type theme_values
dark_theme = {
  bg = playdate.graphics.kColorBlack,
  fg = playdate.graphics.kColorWhite,
  bg_pattern = playdate.graphics.image.new("assets/images/patterns/forwardslash_dark")
    or error("Failed to load 'assets/images/patterns/forwardslash_dark.png'"),
}

---@type theme_values
light_theme = {
  bg = playdate.graphics.kColorWhite,
  fg = playdate.graphics.kColorBlack,
  bg_pattern = playdate.graphics.image.new("assets/images/patterns/forwardslash_light")
    or error("Failed to load 'assets/images/patterns/forwardslash_light.png'"),
}

local themes = {
  dark = dark_theme,
  light = light_theme,
}

---@class theme
---@field values theme_values
---@field version number
theme = {
  values = themes[config:read_theme()],
  version = 0,
}

---@alias theme_name "dark" | "light"

---@param new_theme theme_name
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

function theme:is_dark_theme()
  return self.values == dark_theme
end