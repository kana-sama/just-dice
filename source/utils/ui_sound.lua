local function new_synth(a, d, s, r, volume, sound)
	local synth = playdate.sound.synth.new(sound)
	synth:setADSR(a, d, s, r)
	synth:setVolume(volume)
	return synth
end

UISound = {
  beep = new_synth(0, 0.04, 0, 0, 0.25, playdate.sound.kWaveSawtooth),
  blop = new_synth(0, 0.1, 0, 0.2, 0.4, playdate.sound.kWavePOVosim),
}

function UISound:start_selection()
  UISound:move_cursor()
end

function UISound:cancel_selection()
  self.beep:playNote(100)
end

function UISound:move_cursor()
  self.blop:playNote(1000)
end

function UISound:activate_die()
  self.beep:playNote(400)
end

function UISound:deactivate_die()
  self.beep:playNote(200)
end