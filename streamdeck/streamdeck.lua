local streamdeck = {}
local log = hs.logger.new("streamdeck", "info")

-- Streamdeck state
streamdeck.profiles = {}
streamdeck.layers = {}
streamdeck.currentLayer = "default"
streamdeck.currentLayout = nil
streamdeck.device = nil
streamdeck.update_timer = nil
streamdeck.isLocked = false

-- Callback for use as a streamdeck key callback
function streamdeck.changeLayerCallback(layer)
  return function()
    streamdeck.changeLayer(layer)
  end
end

function streamdeck.buttonCallback(sd, button_number, pressed)
  if streamdeck.isLocked or sd ~= streamdeck.device then
    return
  end

  local layer = streamdeck.layers[streamdeck.currentLayer]
  if not layer then
    return
  end

  local button = layer[button_number] or {}

  -- Deal with passthrough buttons
  if button.passthrough then
    local passthroughLayer = streamdeck.layers[button.passthrough] or {}
    button = passthroughLayer[button_number] or {}
  end

  if pressed and button.press_callback then
    button.press_callback()
  elseif button.release_callback then
    button.release_callback()
  end

  -- Update button status after pressing any button, so we get a faster
  -- response on button updates. Don't do it too quickly though.
  streamdeck.updateStatusSoon()
end

function streamdeck.changeLayer(layer)
  if not streamdeck.layers[layer] then
    log.w("Ignoring unknown Stream Deck layer: " .. tostring(layer))
    return
  end

  streamdeck.currentLayer = layer
  for idx, button in ipairs(streamdeck.layers[streamdeck.currentLayer]) do
    streamdeck.updateButtonImage(idx, button)
  end
end

function streamdeck.updateButtonImage(idx, button)
  -- Don't update any images if the screen is locked
  if streamdeck.isLocked or not streamdeck.device then
    return
  end

  button = button or {}

  -- Deal with passthrough buttons
  if button.passthrough then
    local passthroughLayer = streamdeck.layers[button.passthrough] or {}
    button = passthroughLayer[idx] or {}
  end

  if button and button.status_image then
    streamdeck.device:setButtonImage(idx, button.status_image)
  elseif button and button.image then
    streamdeck.device:setButtonImage(idx, button.image)
  else
    streamdeck.device:setButtonColor(idx, hs.drawing.color.hammerspoon.black)
  end
end

function streamdeck.runUpdateCallbacks()
  for layerid, layer in pairs(streamdeck.layers) do
    for idx, button in ipairs(layer) do
      if button.update_callback then
        local old_status_image = button.status_image
        button:update_callback()
        -- Update the button image it's visible and the image changed
        local currentLayer = streamdeck.layers[streamdeck.currentLayer] or {}
        local currentButton = currentLayer[idx] or {}
        if currentButton.passthrough == layerid
          or layerid == streamdeck.currentLayer then
          if button.status_image ~= old_status_image then
            streamdeck.updateButtonImage(idx, button)
          end
        end
      end
    end
  end
end

function streamdeck.setupUpdateTimer()
  streamdeck.cancelUpdateTimer()
  streamdeck.update_timer = hs.timer.doEvery(5, streamdeck.runUpdateCallbacks)
  -- Initial run
  streamdeck.runUpdateCallbacks()
end

function streamdeck.cancelUpdateTimer()
  if streamdeck.update_timer then
    streamdeck.update_timer:stop()
    streamdeck.update_timer = nil
  end
  if streamdeck.quick_update_timer then
    streamdeck.quick_update_timer:stop()
    streamdeck.quick_update_timer = nil
  end
end

function streamdeck.updateStatusSoon()
  -- Set up a one-shot timer to update status soon (after 1 second) that can be
  -- called after pressing a button to show any changes to the button status
  -- that happen as a result of pressing the button. We use a timer because
  -- some actions are a bit slow to actually show an update.
  if streamdeck.quick_update_timer then
    -- Cancel any existing timer so we don't have lots of them if we press a
    -- button over and over
    streamdeck.quick_update_timer:stop()
  end
  streamdeck.quick_update_timer = hs.timer.doAfter(1,
    streamdeck.runUpdateCallbacks)
  -- Also try running the update callback immediately to get a more immediate
  -- response in the event the action is not slow
  streamdeck.runUpdateCallbacks()
end

function streamdeck.layoutKey(sd)
  local cols, rows = sd:buttonLayout()
  return string.format("%dx%d", cols, rows)
end

function streamdeck.selectProfile(sd)
  local layoutKey = streamdeck.layoutKey(sd)
  local profile = streamdeck.profiles[layoutKey]

  if not profile then
    streamdeck.currentLayout = layoutKey
    streamdeck.layers = {}
    streamdeck.currentLayer = "default"
    hs.alert.show("Unsupported Stream Deck layout: " .. layoutKey)
    log.w("Unsupported Stream Deck layout: " .. layoutKey)
    return false
  end

  streamdeck.currentLayout = layoutKey
  streamdeck.layers = profile.layers or profile
  streamdeck.currentLayer = profile.defaultLayer or "default"
  log.i("Using Stream Deck layout: " .. layoutKey)
  return true
end

function streamdeck.deviceConnectedCallback(connected, sd)
  if connected then
    streamdeck.device = sd
  else
    if sd == streamdeck.device then
      streamdeck.device = nil
      streamdeck.layers = {}
      streamdeck.currentLayout = nil
      streamdeck.cancelUpdateTimer()
    end
    return
  end

  if not streamdeck.selectProfile(sd) then
    return
  end

  streamdeck.changeLayer(streamdeck.currentLayer)
  streamdeck.setupUpdateTimer()
  streamdeck.setupLockScreenMonitoring()
  sd:buttonCallback(streamdeck.buttonCallback)
end

function streamdeck.blankScreen()
  if not streamdeck.device then
    return
  end

  local cols, rows = streamdeck.device:buttonLayout()
  local numButtons = rows * cols
  for idx = 1,numButtons do
    streamdeck.device:setButtonColor(idx, hs.drawing.color.hammerspoon.black)
  end
end

function streamdeck.updateScreenLocked(isLocked)
  streamdeck.isLocked = isLocked
  if isLocked then
    streamdeck.blankScreen()
  else
    streamdeck.changeLayer(streamdeck.currentLayer)
  end
end

function streamdeck.setupLockScreenMonitoring()
  -- Set initial state
  local sessionProperties = hs.caffeinate.sessionProperties()
  streamdeck.updateScreenLocked(sessionProperties.CGSSessionScreenIsLocked)
  -- Start the watcher
  if not streamdeck.caffeinateWatcher then
    streamdeck.caffeinateWatcher = hs.caffeinate.watcher.new(function(e)
      if e == hs.caffeinate.watcher.screensDidLock then
        streamdeck.updateScreenLocked(true)
      elseif e == hs.caffeinate.watcher.screensDidUnlock then
        streamdeck.updateScreenLocked(false)
      end
    end)
    streamdeck.caffeinateWatcher:start()
  end
end

function streamdeck.init(profiles)
  streamdeck.profiles = profiles
  hs.streamdeck.init(streamdeck.deviceConnectedCallback)
end

return streamdeck
