local streamdeck = {}

-- Streamdeck state
streamdeck.layers = {}
streamdeck.currentLayer = 'default'
streamdeck.device = nil

-- Callback for use as a streamdeck key callback
function streamdeck.changeLayerCallback(layer)
  return function()
    streamdeck.changeLayer(layer)
  end
end

function streamdeck.buttonCallback(sd, button_number, pressed)
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
  end

  streamdeck.changeLayer('default')
  sd:buttonCallback(streamdeck.buttonCallback)
end

function streamdeck.init(layers)
  streamdeck.layers = layers
  hs.streamdeck.init(streamdeck.deviceConnectedCallback)
end

return streamdeck
