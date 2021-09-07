---- Hammerspoon config ----

---- Load modules ----
local fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

local audio = require("audio")
local hotkeys = require("hotkeys")
local windowmanage = require("windowmanage")
local zoom_detect = require("zoom_detect")

---- Automatically reload the config ----
pw1 = hs.pathwatcher.new(os.getenv("HOME") ..
    "/.hammerspoon/", hs.reload):start()
-- I manage my dotfiles in a different dir and symlink to ~/.hammerspoon
pw2 = hs.pathwatcher.new(os.getenv("HOME") ..
    ".dotfiles/dotfiles-laptop/home/.hammerspoon/", hs.reload):start()
hs.notify.show("Hammerspoon",  "", "config loaded", "")

-- Force garbage collection early to quickly detect any issues caused by use
-- of local variables and garbage collection.
hs.timer.doAfter(5, collectgarbage)
