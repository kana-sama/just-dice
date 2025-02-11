---@generic T
---@param value T | nil
---@param default T
---@return T
local function with_default(value, default)
  return value == nil and default or value
end

---@class config_data
---@field is_dark_theme boolean
---@field framerate boolean
---@field pattern boolean

local data = playdate.datastore.read("config") or {}

---@class config
---@field stored config_data
config = {
  stored = {
    is_dark_theme = with_default(data.is_dark_theme, false);
    framerate = with_default(data.framerate, false);
    pattern = with_default(data.pattern, true);
  }
}

---@param is_dark_theme boolean
function config:set_dark_theme(is_dark_theme)
  config.stored.is_dark_theme = is_dark_theme
  self:save()
end

---@param framerate boolean
function config:set_framerate(framerate)
  config.stored.framerate = framerate
  self:save()
end

---@param pattern boolean
function config:set_pattern(pattern)
  config.stored.pattern = pattern
  self:save()
end

function config:save()
  playdate.datastore.write(config.stored, "config", true)
end