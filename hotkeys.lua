---- Hotkeys ----
local actions = require("actions")
local ptt = require("ptt")

-- Normal hotkeys
hs.hotkey.bind({"cmd", "alt"}, "L", actions.sleep_screen)

-- Launchpad hotkeys (Keys are mapped from F13-F20)
-- Note: F13-F15 are also Pause, Scroll Lock, Print Screen on PC keyboards
-- hs.hotkey.bind({}, "F13", ...) -- F13 is used for PTT
ptt.setupPTTHotkey({}, "F13")
hs.hotkey.bind({}, "F14", actions.reset_mic_volume)
hs.hotkey.bind({}, "F15", actions.pause_music)
hs.hotkey.bind({}, "F19", actions.audio_headset)
hs.hotkey.bind({}, "F20", actions.audio_speaker)

-- Hyper key (caps lock) bindings
local hyper_mods = {"ctrl", "alt", "cmd", "shift"}
function hyper_bind(key, callback)
    hs.hotkey.bind(hyper_mods, key, callback)
end

ptt.setupPTTHotkey(hyper_mods, "A")
hyper_bind("L", actions.sleep_screen)
hyper_bind("P", actions.pause_music)
hyper_bind("H", actions.audio_headset)
hyper_bind("S", actions.audio_speaker)

