local streamdeck = {}
local log = hs.logger.new("streamdeck", "info")

-- Streamdeck state
streamdeck.profiles = {}
streamdeck.profileStates = {}
streamdeck.layers = {}
streamdeck.currentLayer = "default"
streamdeck.currentLayout = nil
streamdeck.device = nil
streamdeck.update_timer = nil
streamdeck.isLocked = false
streamdeck.app_reconcile_delay = 0.1

-- Return a callback that switches to a layer as a manual action.
-- This is itself used as a callback function for streamdeck keys
-- to change layers manually.
function streamdeck.changeLayerCallback(layer)
  return function()
    streamdeck.changeLayer(layer, {manual = true})
  end
end

-- Return the selected profile for the currently active Stream Deck layout.
function streamdeck.currentProfile()
  return streamdeck.profiles[streamdeck.currentLayout]
end

-- Return persistent automation state for a Stream Deck layout profile.
function streamdeck.profileState(layoutKey)
  local profile = streamdeck.profiles[layoutKey]
  local defaultLayer = profile and profile.defaultLayer or "default"

  if not streamdeck.profileStates[layoutKey] then
    streamdeck.profileStates[layoutKey] = {
      activeAppName = nil,
      lastManualLayer = defaultLayer,
      manualOverrideAppName = nil,
    }
  end

  return streamdeck.profileStates[layoutKey]
end

-- Return persistent automation state for the active layout profile.
function streamdeck.currentProfileState()
  if not streamdeck.currentLayout then
    return nil
  end
  return streamdeck.profileState(streamdeck.currentLayout)
end

-- Return the configured Stream Deck layer for an app name, if any.
function streamdeck.appLayerForName(appName)
  local profile = streamdeck.currentProfile()
  if not profile or not profile.appLayers then
    return nil
  end

  return profile.appLayers[appName]
end

-- Return a button from a layer without following passthrough entries.
function streamdeck.rawButtonForLayer(layerName, idx)
  local layer = streamdeck.layers[layerName] or {}
  return layer[idx] or {}
end

-- Resolve a layer button, following passthrough entries when present.
function streamdeck.buttonForLayer(layerName, idx)
  local button = streamdeck.rawButtonForLayer(layerName, idx)
  if button.passthrough then
    button = streamdeck.rawButtonForLayer(button.passthrough, idx)
  end

  return button
end

-- Handle Stream Deck button presses and releases for the active device.
function streamdeck.buttonCallback(sd, button_number, pressed)
  if streamdeck.isLocked or sd ~= streamdeck.device then
    return
  end

  if not streamdeck.layers[streamdeck.currentLayer] then
    return
  end

  local button = streamdeck.buttonForLayer(
    streamdeck.currentLayer,
    button_number
  )

  if pressed and button.press_callback then
    button.press_callback()
  elseif button.release_callback then
    button.release_callback()
  end

  -- Update button status after pressing any button, so we get a faster
  -- response on button updates. Don't do it too quickly though.
  streamdeck.updateStatusSoon()
end

-- Return the frontmost app name if it has a layer mapping in this profile.
function streamdeck.frontmostWatchedAppName()
  local appName, appLayer = streamdeck.frontmostAppLayer()
  if appLayer then
    return appName
  end
  return nil
end

-- Return the frontmost app name and configured layer, if mapped.
function streamdeck.frontmostAppLayer()
  local frontmostApp = hs.application.frontmostApplication()
  local appName = frontmostApp and frontmostApp:name()
  return appName, streamdeck.appLayerForName(appName)
end

-- Switch to a layer, optionally recording it as a manual layer choice.
function streamdeck.changeLayer(layer, options)
  local options = options or {}
  if not streamdeck.layers[layer] then
    log.w("Ignoring unknown Stream Deck layer: " .. tostring(layer))
    return false
  end

  streamdeck.currentLayer = layer
  streamdeck.redrawCurrentLayer()

  if options.manual and streamdeck.currentLayout then
    local state = streamdeck.currentProfileState()
    state.lastManualLayer = layer
    state.manualOverrideAppName = streamdeck.frontmostWatchedAppName()
  end

  return true
end

-- Render every button in the current layer.
function streamdeck.redrawCurrentLayer()
  for idx, button in ipairs(streamdeck.layers[streamdeck.currentLayer]) do
    streamdeck.updateButtonImage(idx, button)
  end
end

-- Render one button image, status image, or blank color to the device.
function streamdeck.updateButtonImage(idx, button)
  -- Don't update any images if the screen is locked
  if streamdeck.isLocked or not streamdeck.device then
    return
  end

  button = button or {}
  if button.passthrough then
    button = streamdeck.buttonForLayer(button.passthrough, idx)
  end

  if button.status_image then
    streamdeck.device:setButtonImage(idx, button.status_image)
  elseif button.image then
    streamdeck.device:setButtonImage(idx, button.image)
  else
    streamdeck.device:setButtonColor(idx, hs.drawing.color.hammerspoon.black)
  end
end

-- Run every button status callback and update visible changed buttons.
function streamdeck.runUpdateCallbacks()
  for layerid, layer in pairs(streamdeck.layers) do
    for idx, button in ipairs(layer) do
      if button.update_callback then
        local old_status_image = button.status_image
        button:update_callback()
        -- Update the button image it's visible and the image changed
        local currentButton = streamdeck.rawButtonForLayer(
          streamdeck.currentLayer,
          idx
        )
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

-- Start the recurring status update timer for the active device.
function streamdeck.setupUpdateTimer()
  streamdeck.cancelUpdateTimer()
  streamdeck.update_timer = hs.timer.doEvery(5, streamdeck.runUpdateCallbacks)
  -- Initial run
  streamdeck.runUpdateCallbacks()
end

-- Stop pending status update timers.
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

-- Refresh status callbacks soon after an action changes external state.
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

-- Return a layout key like "5x3" for a connected Stream Deck.
function streamdeck.layoutKey(sd)
  local cols, rows = sd:buttonLayout()
  return string.format("%dx%d", cols, rows)
end

-- Select the profile that matches the connected Stream Deck layout.
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
  local state = streamdeck.profileState(layoutKey)
  streamdeck.currentLayer = state.lastManualLayer or profile.defaultLayer
    or "default"
  log.i("Using Stream Deck layout: " .. layoutKey)
  return true
end

-- Debounce app layer reconciliation to avoid app event ordering flicker.
function streamdeck.scheduleAppLayerReconcile()
  if streamdeck.app_reconcile_timer then
    streamdeck.app_reconcile_timer:stop()
  end

  streamdeck.app_reconcile_timer = hs.timer.doAfter(
    streamdeck.app_reconcile_delay,
    streamdeck.reconcileAppLayer
  )
end

-- Apply an app-specific layer unless the user manually overrode it.
function streamdeck.applyAppLayer(state, appName, appLayer)
  if state.manualOverrideAppName == appName then
    return
  end

  if streamdeck.changeLayer(appLayer, {manual = false}) then
    state.activeAppName = appName
    state.manualOverrideAppName = nil
  else
    log.w("Ignoring missing app layer: " .. appLayer)
  end
end

-- Restore the last manual layer after leaving app-specific layer mode.
function streamdeck.restoreManualLayer(state)
  local profile = streamdeck.currentProfile()
  local restoreLayer = state.lastManualLayer or profile.defaultLayer
    or "default"
  streamdeck.changeLayer(restoreLayer, {manual = false})
  state.activeAppName = nil
  state.manualOverrideAppName = nil
end

-- Reconcile the current layer against the actual frontmost application.
function streamdeck.reconcileAppLayer()
  if not streamdeck.device or not streamdeck.currentLayout then
    return
  end

  local state = streamdeck.currentProfileState()
  local appName, appLayer = streamdeck.frontmostAppLayer()

  if appLayer then
    streamdeck.applyAppLayer(state, appName, appLayer)
  elseif state.activeAppName then
    streamdeck.restoreManualLayer(state)
  end
end

-- Start the application watcher that drives app-specific layer changes.
function streamdeck.setupAppWatcher()
  if streamdeck.appWatcher then
    return
  end

  streamdeck.appWatcher = hs.application.watcher.new(
    function(appName, eventType, app)
      if eventType == hs.application.watcher.activated
        or eventType == hs.application.watcher.deactivated
        or eventType == hs.application.watcher.terminated then
        streamdeck.scheduleAppLayerReconcile()
      end
    end
  )
  streamdeck.appWatcher:start()
end

-- Handle Stream Deck connect and disconnect events.
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

  streamdeck.changeLayer(streamdeck.currentLayer, {manual = false})
  streamdeck.setupUpdateTimer()
  streamdeck.setupLockScreenMonitoring()
  streamdeck.setupAppWatcher()
  streamdeck.scheduleAppLayerReconcile()
  sd:buttonCallback(streamdeck.buttonCallback)
end

-- Clear every button on the active Stream Deck.
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

-- Update screen lock state and blank or redraw the Stream Deck.
function streamdeck.updateScreenLocked(isLocked)
  streamdeck.isLocked = isLocked
  if isLocked then
    streamdeck.blankScreen()
  else
    streamdeck.changeLayer(streamdeck.currentLayer, {manual = false})
    streamdeck.scheduleAppLayerReconcile()
  end
end

-- Start monitoring macOS lock and unlock events.
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

-- Initialize the Stream Deck runtime with all layout profiles.
function streamdeck.init(profiles)
  streamdeck.profiles = profiles
  hs.streamdeck.init(streamdeck.deviceConnectedCallback)
end

return streamdeck
