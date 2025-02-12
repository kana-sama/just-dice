INITIAL_DICE_COUNT = 3
MAX_DICE_COUNT = 9
DIE_SIZE = 55

Z_INDICES = {
  background = 0,
  die_shadow = 1,
  die = 2,
  cursor = 3,
  lock = 4,
  fade = 5,
}

import "CoreLibs/math"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/animator"
import "CoreLibs/utilities/sampler"

import "utils/classic"
import "utils/lerp"
import "utils/vector3d"
import "utils/progress"
import "utils/smooth"
import "utils/ring_buffer"
import "utils/list"
import "utils/image"
import "utils/disabled_animator"
import "utils/coroutine"
import "utils/rect"
import "utils/ui_sound"

import "services/shaking"
import "services/config"
import "services/stat"
import "services/theme"
import "services/input"

import "components/background"
import "components/fade"
import "components/lock"
import "components/die"
import "components/cursor"

import "game"

playdate.display.setRefreshRate(50.0)

playdate.startAccelerometer()

playdate.getSystemMenu():addOptionsMenuItem(
  "theme", { "dark", "light" }, config.stored.is_dark_theme and "dark" or "light",
  function(new_theme)
    local is_dark_theme = new_theme == "dark"
    theme:set_dark_theme(is_dark_theme)
    config:set_dark_theme(is_dark_theme)
  end
)

playdate.getSystemMenu():addCheckmarkMenuItem(
  "framerate", config.stored.framerate,
  function(framerate)
    config:set_framerate(framerate)
  end
)

playdate.getSystemMenu():addCheckmarkMenuItem(
  "pattern", config.stored.pattern,
  function(pattern)
    config:set_pattern(pattern)
  end
)

function playdate.gameWillPause()
  playdate.setMenuImage(stat:render())
end

local game = Game()

---@diagnostic disable-next-line: duplicate-set-field
function playdate.update()
  playdate.graphics.setBackgroundColor(theme:background_color())

  input:update()
  game:update()

  playdate.graphics.sprite:update()

  if config.stored.framerate then
    playdate.drawFPS(0, 0)
  end
end

-- import "generators/positions"
-- import "generators/dice"