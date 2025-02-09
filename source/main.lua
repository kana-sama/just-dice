import "CoreLibs/math"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/animator"
import "CoreLibs/utilities/sampler"

import "utils/classic"
import "utils/lerp"
import "utils/vector3d"
import "utils/progress"
import "utils/ring_buffer"

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

DIE_SIZES = {
  [1] = 70,
  [2] = 70,
  [3] = 60,
  [4] = 60,
  [5] = 50,
  [6] = 50,
}

playdate.display.setRefreshRate(50.0)
playdate.startAccelerometer()

playdate.getSystemMenu():addOptionsMenuItem(
  "Theme", { "dark", "light" },
  config:read_theme(), function(new_theme)
    theme:set(new_theme)
    config:write_theme(new_theme)
  end
)

function playdate.gameWillPause()
  playdate.setMenuImage(stat:render())
end

local game = Game()

function playdate.update()
  game:update()
  playdate.graphics.sprite:update()
  -- playdate.drawFPS(0, 0)
end
