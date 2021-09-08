-- Make sure hotkey functions are loaded so we can refer to them as streamdeck
-- callbacks
require("hotkeys")
require("streamdeck/images")

-- Callback for use as a streamdeck key callback
function streamdeck_changeLayerCallback(layer)
  return function()
    streamdeck_changeLayer(layer)
  end
end

local layers = {
  -- Layer 1 - Main layer
  {
    -- Row 1
    { },
    {
      image = streamdeck_imageFromText("🔉", "Mic Vol"),
      press_callback = hotkey_reset_mic_volume
    },
    {
      image = streamdeck_imageWithLabel("slack.png", "Away", {yoffset=0}),
      press_callback = hotkey_away
    },
    {
      image = streamdeck_imageWithLabel("slack.png", "Back", {yoffset=0}),
      press_callback = hotkey_back
    },
    {
      image = streamdeck_imageFromText("2", "Layer"),
      press_callback = streamdeck_changeLayerCallback(2)
    },
    -- Row 2
    {
      image = streamdeck_imageFromText("🎧", "Headset"),
      press_callback = hotkey_audio_headset,
    },
    {
      image = streamdeck_imageFromText("🔈", "Speaker"),
      press_callback = hotkey_audio_speaker,
    },
    {
      image = streamdeck_imageFromText("💻", "Laptop Speaker"),
      press_callback = hotkey_audio_laptop,
    },
    {},
    {},
    -- Row 3
    {
      image = streamdeck_imageWithLabel('shush.png', 'Shush', {
        scale = 0.75, yoffset = 10}),
      press_callback = function() hs.eventtap.event.newKeyEvent("F13", true):post() end,
      release_callback = function() hs.eventtap.event.newKeyEvent("F13", false):post() end,
    },
    {},
    {},
    {},
    {},
  },

  -- Layer 2
  {
    -- Row 1
    {},
    {},
    {},
    {},
    {
      image = streamdeck_imageFromText("<", "Back"),
      press_callback = streamdeck_changeLayerCallback(1)
    },
    -- Row 2
    {},
    {},
    {},
    {},
    {},
    -- Row 3
    {
      -- Shush
      passthrough = true
    },
    {},
    {},
    {},
    {},
  },
  -- Layer N - Blank template layer
  {
    -- Row 1
    {},
    {},
    {},
    {},
    {},
    -- Row 2
    {},
    {},
    {},
    {},
    {},
    -- Row 3
    {},
    {},
    {},
    {},
    {},
  },
}

function streamdeck_buttonCallback(sd, button_number, pressed)
  -- If a button has the passthrough attribute set, keep going up a layer
  -- until we find a non-passthrough button
  local buttonLayer = currentLayer
  repeat
    button = layers[buttonLayer][button_number]
    buttonLayer = buttonLayer - 1
  until buttonLayer == 0 or not button.passthrough

  if pressed and button.press_callback then
    button.press_callback()
  elseif button.release_callback then
    button.release_callback()
  end
end


function streamdeck_changeLayer(layer)
  currentLayer = layer
  for idx, button in ipairs(layers[currentLayer]) do

    -- Deal with passthrough layers
    local buttonLayer = currentLayer
    repeat
      button = layers[buttonLayer][idx]
      buttonLayer = buttonLayer - 1
    until buttonLayer == 0 or not button.passthrough

    if button and button.image then
      streamdeckDevice:setButtonImage(idx, button.image)
    else
      streamdeckDevice:setButtonImage(idx, streamdeck_blankImage())
    end
  end
end

function streamdeck_init(connected, sd)
  if connected then
    streamdeckDevice = sd
  else
    streamdeckDevice = nil
  end

  streamdeck_changeLayer(1)
  sd:buttonCallback(streamdeck_buttonCallback)
end

hs.streamdeck.init(streamdeck_init)
