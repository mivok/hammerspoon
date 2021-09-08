local zoom_actions = {}

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
        return true
      end
    end
  end
  return false
end

function zoom_actions.audio_toggle()
  zoom_actions.select_menu_items({"Mute audio", "Unmute audio"})
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
  -- Click close, wait a bit, then press Enter to confirm
  if zoom_actions.select_menu_items({{"Window", "Close"}}) then
    hs.timer.doAfter(0.5, function()
      local app = hs.application.find("zoom.us")
      hs.eventtap.keyStroke({}, "Enter", nil, app)
    end)
  end
end

return zoom_actions
