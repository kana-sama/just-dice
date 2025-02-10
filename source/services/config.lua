---@generic T
---@param value T | nil
---@param default T
---@return T
local function with_default(value, default)
  return value == nil and default or value
end

---@class config
config = playdate.datastore.read("config") or {}
config.is_dark_theme = with_default(config.is_dark_theme, false)
config.framerate = with_default(config.framerate, false)
config.pattern = with_default(config.pattern, true)

---@param is_dark_theme boolean
function config.set_dark_theme(is_dark_theme)
  config.is_dark_theme = is_dark_theme
  playdate.datastore.write(config, "config")
end

---@param framerate boolean
function config.set_framerate(framerate)
  config.framerate = framerate
  playdate.datastore.write(config, "config")
end

---@param pattern boolean
function config.set_pattern(pattern)
  config.pattern = pattern
  playdate.datastore.write(config, "config")
end
