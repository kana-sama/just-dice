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
import "utils/list"
import "utils/image"

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
  background = 0,
  die = 1,
  lock = 2,
  fade = 3,
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
  "theme", { "dark", "light" }, config.is_dark_theme and "dark" or "light",
  function(new_theme)
    local is_dark_theme = new_theme == "dark"
    theme:set_dark_theme(is_dark_theme)
    config.set_dark_theme(is_dark_theme)
  end
)

playdate.getSystemMenu():addCheckmarkMenuItem(
  "framerate", config.framerate,
  function(framerate)
    config.set_framerate(framerate)
  end
)

playdate.getSystemMenu():addCheckmarkMenuItem(
  "pattern", config.pattern,
  function(pattern)
    config.set_pattern(pattern)
  end
)

function playdate.gameWillPause()
  playdate.setMenuImage(stat:render())
end

local game = Game()

function playdate.update()
  game:update()

  playdate.graphics.sprite:update()

  if config.framerate then
    playdate.drawFPS(0, 0)
  end
end
