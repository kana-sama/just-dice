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

---@class theme
theme = {
  values = config.stored.is_dark_theme and dark_theme or light_theme,
  version = 0,
}

---@return pd_color
function theme:background_color()
  return self.values.bg
end

---@return pd_color
function theme:foreground_color()
  return self.values.fg
end

---@return pd_image
function theme:background_pattern()
  return self.values.bg_pattern
end

---@return pd_draw_mode
function theme:text_draw_mode()
  if self.values.fg == playdate.graphics.kColorBlack then
    return playdate.graphics.kDrawModeFillBlack
  else
    return playdate.graphics.kDrawModeFillWhite
  end
end

---@param is_dark_theme boolean
function theme:set_dark_theme(is_dark_theme)
  self.values = is_dark_theme and dark_theme or light_theme
  self.version = self.version + 1
end

---@return boolean
function theme:is_dark_theme()
  return self.values == dark_theme
end
