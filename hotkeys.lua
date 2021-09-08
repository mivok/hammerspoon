---- Hotkeys ----
local actions = require("actions")

-- Normal hotkeys
hs.hotkey.bind({"cmd", "alt"}, "L", actions.sleep_screen)

-- Launchpad hotkeys (Keys are mapped from F13-F20)
-- hs.hotkey.bind({}, "F13", ...) -- F13 is used for shush
hs.hotkey.bind({}, "F14", actions.reset_mic_volume)
hs.hotkey.bind({}, "F15", actions.pause_music)
hs.hotkey.bind({}, "F17", actions.slack_away)
hs.hotkey.bind({}, "F18", actions.slack_back)
hs.hotkey.bind({}, "F19", actions.audio_headset)
hs.hotkey.bind({}, "F20", actions.audio_speaker)

-- Hyper key (caps lock) bindings
function hyper_bind(key, callback)
    hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, key, callback)
end

hyper_bind("A", actions.slack_away)
hyper_bind("B", actions.slack_back)
hyper_bind("L", actions.sleep_screen)
hyper_bind("P", actions.pause_music)
hyper_bind("H", actions.audio_headset)
hyper_bind("S", actions.audio_speaker)
