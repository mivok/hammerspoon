---- Hotkeys ----
local actions = require("actions")
local ptt = require("ptt")

-- Descriptions appear in help; actions provide their own alerts.
hs.hotkey.alertDuration = 0

-- Normal hotkeys
hs.hotkey.bind({"cmd", "alt"}, "L", "Lock screen", actions.lock_screen)

-- Hyper key (caps lock) bindings
local hyper_mods = {"ctrl", "alt", "cmd", "shift"}
local function hyper_bind(key, description, callback)
  return hs.hotkey.bind(hyper_mods, key, description, callback)
end

hyper_bind("L", "Lock screen", actions.lock_screen)
hyper_bind("P", "Play/pause media", actions.pause_music)

-- Audio and microphone controls
ptt.setupPTTHotkey(hyper_mods, "A")
hyper_bind("T", "Toggle push-to-talk / push-to-mute mode", ptt.togglePTTMode)
hyper_bind("E", "Use headset audio", actions.audio_device("headset"))
hyper_bind("S", "Use laptop speakers", actions.audio_device("laptop"))
hyper_bind("M", "Reset microphone volume", actions.reset_mic_volume)

-- Main Stream Deck layer actions
hyper_bind("W", "AWS SSO login", actions.aws_sso_login)
hyper_bind("C", "Send clipboard to personal machine",
  actions.send_clipboard("personal"))
hyper_bind("V", "Get clipboard from personal machine",
  actions.get_clipboard("personal"))

-- Hold Hyper + H to show active shortcuts; release to dismiss.
hs.hotkey.showHotkeys(hyper_mods, "H")

-- Date snippets
local function type_date()
  hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end
hs.hotkey.bind({"ctrl", "alt"}, "D", "Type date (YYYY-MM-DD)", type_date)
