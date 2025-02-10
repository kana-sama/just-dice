local keys = {
  left = playdate.kButtonLeft,
  right = playdate.kButtonRight,
  up = playdate.kButtonUp,
  down = playdate.kButtonDown,
  a = playdate.kButtonA,
  b = playdate.kButtonB,
}

input = {
  left = false,
  right = false,
  up = false,
  down = false,
  a = false,
  b = false,
}

input._waiting_for_release = {}
for key, _ in pairs(keys) do
  input._waiting_for_release[key] = false
end

function input:update()
  for key, pd_key in pairs(keys) do
    self[key] = not self[key] and not self._waiting_for_release[key] and playdate.buttonIsPressed(pd_key)
    self._waiting_for_release[key] = playdate.buttonIsPressed(pd_key)
  end
end
