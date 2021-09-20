local streamdeck = {}

-- Streamdeck state
streamdeck.layers = {}
streamdeck.currentLayer = 'default'
streamdeck.device = nil
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

    -- Deal with passthrough buttons
    if button.passthrough then
      button = streamdeck.layers[button.passthrough][idx]
    end

    if button and button.image then
      streamdeck.device:setButtonImage(idx, button.image)
    else
      streamdeck.device:setButtonColor(idx, hs.drawing.color.hammerspoon.black)
    end
  end
end

function streamdeck.deviceConnectedCallback(connected, sd)
  if connected then
    streamdeck.device = sd
  else
    streamdeck.device = nil
    return
  end

  streamdeck.changeLayer('default')
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
