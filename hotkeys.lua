---- Hotkeys ----
local actions = require("actions")
local ptt = require("ptt")

-- Descriptions appear in help; actions provide their own alerts.
hs.hotkey.alertDuration = 0

-- Normal hotkeys
hs.hotkey.bind({"cmd", "alt"}, "L", "Lock screen", actions.lock_screen)

-- Launchpad hotkeys (Keys are mapped from F13-F20)
-- Note: F13-F15 are also Pause, Scroll Lock, Print Screen on PC keyboards
-- hs.hotkey.bind({}, "F13", ...) -- F13 is used for PTT
ptt.setupPTTHotkey({}, "F13")
hs.hotkey.bind({}, "F14", "Reset microphone volume", actions.reset_mic_volume)
hs.hotkey.bind({}, "F15", "Pause music", actions.pause_music)
hs.hotkey.bind({}, "F19", "Use headset audio", actions.audio_device("headset"))


-- Hyper key (caps lock) bindings
local hyper_mods = {"ctrl", "alt", "cmd", "shift"}
local function hyper_bind(key, description, callback)
  return hs.hotkey.bind(hyper_mods, key, description, callback)
end

ptt.setupPTTHotkey(hyper_mods, "A")
hyper_bind("L", "Lock screen", actions.lock_screen)
hyper_bind("P", "Pause music", actions.pause_music)
hyper_bind("H", "Use headset audio", actions.audio_device("headset"))

-- Hold Hyper + / to show active shortcuts; release to dismiss.
hs.hotkey.showHotkeys(hyper_mods, "/")

-- Date snippets
local function type_date()
  hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end
hs.hotkey.bind({"ctrl", "alt"}, "D", "Type date (YYYY-MM-DD)", type_date)
