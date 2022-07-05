local streamdeck = {}

-- Streamdeck state
streamdeck.layers = {}
streamdeck.currentLayer = 'default'
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
  if streamdeck.isLocked then
    return
  end

  local button = streamdeck.layers[streamdeck.currentLayer][button_number]

  -- Deal with passthrough buttons
  if button.passthrough then
    button = streamdeck.layers[button.passthrough][button_number]
  end

  if pressed and button.press_callback then
    button.press_callback()
  elseif button.release_callback then
    button.release_callback()
  end
end

function streamdeck.changeLayer(layer)
  streamdeck.currentLayer = layer
  for idx, button in ipairs(streamdeck.layers[streamdeck.currentLayer]) do
    streamdeck.updateButtonImage(idx, button)
  end
end

function streamdeck.updateButtonImage(idx, button)
  -- Don't update any images if the screen is locked
  if streamdeck.isLocked then
    return
  end

  -- Deal with passthrough buttons
  if button.passthrough then
    button = streamdeck.layers[button.passthrough][idx]
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
        old_status_image = button.status_image
        button:update_callback()
        -- Update the button image if it changed
        if layerid == streamdeck.currentLayer then
          if button.status_image ~= old_status_image then
            streamdeck.updateButtonImage(idx, button)
          end
        end
      end
    end
  end
end

function streamdeck.setupUpdateTimer()
  streamdeck.update_timer = hs.timer.doEvery(5, streamdeck.runUpdateCallbacks)
  -- Initial run
  streamdeck.runUpdateCallbacks()
end

function streamdeck.cancelUpdateTimer()
  if streamdeck.update_timer then
    streamdeck.update_timer:stop()
    streamdeck.update_timer = nil
  end
end

function streamdeck.deviceConnectedCallback(connected, sd)
  if connected then
    streamdeck.device = sd
  else
    streamdeck.device = nil
    streamdeck.cancelUpdateTimer()
    return
  end

  streamdeck.changeLayer('default')
  streamdeck.setupUpdateTimer()
  streamdeck.setupLockScreenMonitoring()
  sd:buttonCallback(streamdeck.buttonCallback)
end

function streamdeck.blankScreen()
  local rows, cols = streamdeck.device:buttonLayout()
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
  streamdeck.updateScreenLocked(hs.caffeinate.sessionProperties(). CGSSessionScreenIsLocked)
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

function streamdeck.init(layers)
  streamdeck.layers = layers
  hs.streamdeck.init(streamdeck.deviceConnectedCallback)
end

return streamdeck
