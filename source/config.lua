---@class config
config = {}

---@return theme_name
function config:read_theme()
  ---@type table | nil
  local value = playdate.datastore.read("config")

  if value and value.theme and (value.theme == "dark" or value.theme == "light") then
    return value.theme
  else
    return "dark"
  end
end

function config:write_theme(theme)
  local value = playdate.datastore.read("config") or {}
  value.theme = theme
  playdate.datastore.write(value, "config")
end

