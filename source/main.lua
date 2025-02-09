import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/animator"

import "utils/classic"
import "utils/vector3d"
import "utils/progress"

import "services/shaking"
import "services/config"
import "services/stat"
import "services/theme"

import "components/background"
import "components/fade"
import "components/lock"
import "components/die"

import "game"

Z_INDICES = {
  background = -1,
  die = 1,
  lock = 2,
  fade = 10,
}

playdate.display.setRefreshRate(50.0)

playdate.getSystemMenu():addOptionsMenuItem("Theme", {"dark", "light"}, "dark", function(new_theme)
  theme:set(new_theme)
  config:write_theme(new_theme)
end)

function playdate.gameWillPause()
  playdate.setMenuImage(stat:render())
end

local game = Game()

function playdate.update()
  playdate.graphics.sprite:update()
  game:update()
  -- playdate.drawFPS(0,0)
end
