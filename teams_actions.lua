local teams_actions = {}
local application_name = "Microsoft Teams"

teams_actions.logger = hs.logger.new("teams_actions", "debug")

function teams_shortcut(key)
  app = hs.application.find("Microsoft Teams")
  hs.eventtap.keyStroke({"cmd", "shift"}, key, 200000, app)
end

function teams_actions.full_screen()
  app = hs.application.find("Microsoft Teams")
  win = app:mainWindow()
  win:setFullScreen(not win:isFullScreen())
end

function teams_actions.raise_hand()
  teams_shortcut("k")
end

function teams_actions.camera()
  teams_shortcut("o")
end

function teams_actions.mic()
  teams_shortcut("m")
end

function teams_actions.share()
  teams_shortcut("e")
end

function teams_actions.leave()
  teams_shortcut("h")
end

return teams_actions
