local zoom_actions = {}

zoom_actions.logger = hs.logger.new("zoom_actions", "debug")

-- Selects an item from the zoom menu, trying each one in turn until one is
-- found
-- Note: items can be either strings or a table containing a path to a
-- specific menu item (e.g. {"Open"} or {{"File", "Open"}}
-- Returns true if a menu item was successfully clicked
function zoom_actions.select_menu_items(items)
  local app = hs.application.find("zoom.us")
  if app then
    for _, item in ipairs(items) do
      if app:selectMenuItem(item) then
        -- The item was successfully clicked, don't try any others
        zoom_actions.logger.i("Selected Menu Item: " .. hs.inspect(item))
        return true
      end
    end
  end
  return false
end

function zoom_actions.activate_zoom_window()
  local app = hs.application.find("zoom.us")
  local windowTitles = {"Zoom Meeting", "Zoom Webinar"}
  if app then
    if not app:isFrontmost() then
      zoom_actions.logger.i("Activating zoom app")
      app:activate()
    end
    for _, title in ipairs(windowTitles) do
      local window = app:findWindow(title)
      if window then
        zoom_actions.logger.i("Focusing window: " .. title)
        window:focus()
        break
      end
    end
  end
end

function zoom_actions.close_zoom_meeting_window()
  local app = hs.application.find("zoom.us")
  local windowTitles = {"Zoom Meeting", "Zoom Webinar"}
  if app then
    for _, title in ipairs(windowTitles) do
      local window = app:findWindow(title)
      if window then
        zoom_actions.logger.i("Closing window: " .. title)
        return window:close()
      end
    end
  end
end

function zoom_actions.audio_toggle()
  zoom_actions.select_menu_items({"Mute Audio", "Unmute Audio"})
end

function zoom_actions.camera_toggle()
  zoom_actions.select_menu_items({"Stop Video", "Start Video"})
end

function zoom_actions.share_toggle()
  zoom_actions.select_menu_items({"Start Share", "Stop Share"})
end

function zoom_actions.share_pause()
  zoom_actions.select_menu_items({"Pause Share", "Unpause Share"})
end

function zoom_actions.show_participants()
  zoom_actions.select_menu_items({
    "Show Manage Participants",
    "Close Manage Participants"
  })
end

function zoom_actions.show_chat()
  zoom_actions.select_menu_items({"Show Chat", "Close Chat"})
end

-- Try to leave a zoom meeting, and show any prompt that will come up
function zoom_actions.leave_meeting_prompt()
  zoom_actions.select_menu_items({{"Window", "Close"}})
end

-- Leave a meeting and automatically confirm the prompt
-- Note: this may end the meeting for all
function zoom_actions.leave_meeting_no_prompt()
  -- Make sure the zoom window is active and that we aren't sharing the screen
  zoom_actions.select_menu_items({"Stop Share"})
  zoom_actions.close_zoom_meeting_window()
  -- Click close, wait a bit, then press Enter to confirm
  hs.timer.doAfter(0.5, function()
    local app = hs.application.find("zoom.us")
    hs.eventtap.keyStroke({}, "Return", nil, app)
  end)
end

function zoom_actions.toggle_full_screen()
  zoom_actions.select_menu_items({
    {"Meeting", "Fullscreen"},
    {"Meeting", "Exit Fullscreen"},
    {"Window", "Enter Full Screen"},
    {"Window", "Exit Full Screen"}
  })
end

function zoom_actions.toggle_view()
  zoom_actions.select_menu_items({
    {"Meeting", "Gallery View"},
    {"Meeting", "Speaker View"}
  })
end

return zoom_actions
