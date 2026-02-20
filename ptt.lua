-- Push to talk/mute functionality for Hammerspoon
-- Hold the key to talk, release to mute. Double tap the key to toggle between
-- push to talk and push to mute modes.
--
-- Usage:
-- require('ptt')
-- ptt.setupPTThotkey({}, 'F13') -- Set up push to talk on F13 with no modifiers
--
-- You can also use ptt.ptt_press() and ptt.ptt_release() handlers directly,
-- such as in a streamdeck button configuration.
local M = {}

local audio = require('audio')

-- Push to talk status - true is push to talk, false is push to mute
M.ptt = true
-- Expected mute status, used to detect external changes to mute status
M.muted = hs.audiodevice.defaultInputDevice():muted()

-- Double click detection
local double_click_threshold = 0.5
local last_ptt_press_time = 0

-- Change this to 'debug' for more verbose logging
local log = hs.logger.new('ptt', 'info')

-- Sounds
local ptt_toggle_sound = hs.sound.getByFile('sounds/unmute-lock-snick.wav')
local ptt_mute_sound = hs.sound.getByFile('sounds/mute-bop.wav')
local ptt_unmute_sound = hs.sound.getByFile('sounds/unmute-click.wav')

-- Press - if push to talk, unmute. If push to mute, mute.
function M.ptt_press()
  -- Detect a double click
  local now = hs.timer.secondsSinceEpoch()
  if now - last_ptt_press_time < double_click_threshold then
    log.d('PTT Double Press Detected. Toggling PTT mode.')
    ptt_toggle_sound:play()
    M.ptt = not M.ptt -- toggle between push to talk and push to mute
    last_ptt_press_time = 0 -- reset to avoid tripe toggling
    return
  end
  last_ptt_press_time = now

  log.d('PTT Pressed. '.. (M.ptt and 'Unmuting' or 'Muting'))

  -- Play the appropriate sound
  local sound = M.ptt and ptt_unmute_sound or ptt_mute_sound
  sound:play()

  -- Actually mute or unmute the device
  local device = hs.audiodevice.defaultInputDevice()
  device:setMuted(not M.ptt)
  audio.updateMuteStatus(device:muted())

  -- Update expected mute status
  M.muted = not M.ptt
end

-- Release - if push to talk, mute. If push to mute, unmute.
function M.ptt_release()
  log.d('PTT Released. ' .. (M.ptt and 'Muting' or 'Unmuting'))

  -- Play the appropriate sound
  local sound = M.ptt and ptt_mute_sound or ptt_unmute_sound
  sound:play()

  -- Actually mute or unmute the device
  local device = hs.audiodevice.defaultInputDevice()
  device:setMuted(M.ptt)
  audio.updateMuteStatus(device:muted())

  -- Update expected mute status
  M.muted = M.ptt
end

-- Set up  push to talk key. Hold down to talk, release to mute. If double tap,
-- toggle between push to talk and push to mute.
function M.setupPTTHotkey(mods, key)
  hs.hotkey.bind(mods, key,
    M.ptt_press,
    M.ptt_release
  )
end

function M.enforcePTTHandler()
  local device = hs.audiodevice.defaultInputDevice()
  local current_muted = device:muted()

  if current_muted ~= M.muted then
    log.w('Mute status changed outside of PTT. Enforcing PTT status.')
    device:setMuted(M.muted)
    audio.updateMuteStatus(M.muted)
  end
end

  -- Check every second for changes to mute status
M.enforcePTTTimer = hs.timer.doEvery(1, M.enforcePTTHandler)

return M
