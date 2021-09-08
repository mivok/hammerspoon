---- Hammerspoon config ----

---- Load modules ----
local fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

local audio = require("audio")
local hotkeys = require("hotkeys")
local windowmanage = require("windowmanage")
local zoom_detect = require("zoom_detect")
local streamdeck = require("streamdeck")

---- Automatically reload the config ----
pw1 = hs.pathwatcher.new(hs.configdir, function(paths)
  for _, path in ipairs(paths) do
    if path:sub(-4) == ".lua" then
      hs.reload()
      break
    end
  end
end):start()
hs.notify.show("Hammerspoon",  "", "config loaded", "")

-- Force garbage collection early to quickly detect any issues caused by use
-- of local variables and garbage collection.
-- See https://www.hammerspoon.org/go/#variablelife for why this is here
garbageTimer = hs.timer.doAfter(5, function()
  collectgarbage()
  hs.logger.new('garbage', 'debug'):i("Collected Garbage")
end)
