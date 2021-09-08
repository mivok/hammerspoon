-- Make sure hotkey functions are loaded so we can refer to them as streamdeck
-- callbacks
local images = require("streamdeck/images")
local actions = require("actions")
local zoom_actions = require("zoom_actions")

-- Callback for use as a streamdeck key callback
function streamdeck_changeLayerCallback(layer)
  return function()
    streamdeck_changeLayer(layer)
  end
end

local layers = {
  -- Layer 1 - Main layer
  default = {
    -- Row 1
    { },
    {
      image = images.imageFromText("🔉", "Mic Vol"),
      press_callback = actions.reset_mic_volume
    },
    {
      image = images.imageWithLabel("slack.png", "Away", {yoffset=0}),
      press_callback = actions.slack_away
    },
    {
      image = images.imageWithLabel("slack.png", "Back", {yoffset=0}),
      press_callback = actions.slack_back
    },
    {
      image = images.imageFromText("2", "Layer"),
      press_callback = streamdeck_changeLayerCallback('layer2')
    },
    -- Row 2
    {
      image = images.imageFromText("🎧", "Headset"),
      press_callback = actions.audio_headset,
    },
    {
      image = images.imageFromText("🔈", "Speaker"),
      press_callback = actions.audio_speaker,
    },
    {
      image = images.imageFromText("💻", "Laptop Speaker"),
      press_callback = actions.audio_laptop,
    },
    {},
    {
      image = images.imageWithLabel("zoom.png", "Zoom", {scale=0.6}),
      press_callback = streamdeck_changeLayerCallback('zoom')
    },
    -- Row 3
    {
      image = images.imageWithLabel('shush.png', 'Shush', {
        scale = 0.75, yoffset = 10}),
      press_callback = actions.keydown("F13"),
      release_callback = actions.keyup("F13"),
    },
    {},
    {},
    {},
    {
      image = images.imageFromText("🔒", "", {yoffset=0}),
      press_callback = actions.sleep_screen,
    },
  },

  -- Layer 2
  layer2 = {
    -- Row 1
    {},
    {},
    {},
    {},
    {
      image = images.imageFromText("<", "Back"),
      press_callback = streamdeck_changeLayerCallback('default')
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
      passthrough = 'default'
    },
    {},
    {},
    {},
    {},
  },
  -- Layer 3 - Zoom Layer
  zoom = {
    -- Row 1
    {},
    {passthrough = 'default'}, -- Mic volume reset
    {},
    {
      image = images.imageFromText(".", "Participants"),
      press_callback = zoom_actions.show_participants,
    },
    {
      image = images.imageFromText(".", "Chat"),
      press_callback = zoom_actions.show_chat,
    },
    -- Row 2
    {passthrough = 'default'}, -- Headset
    {passthrough = 'default'}, -- Speaker
    {passthrough = 'default'}, -- Laptop
    {
      image = images.imageFromText(".", "Share Pause"),
      press_callback = zoom_actions.share_pause,
    },
    {
      image = images.imageFromText("<", "Back"),
      press_callback = streamdeck_changeLayerCallback('default')
    },
    -- Row 3
    {
      -- Shush
      passthrough = 'default'
    },
    {
      image = images.imageFromText("M", "Mute"),
      press_callback = zoom_actions.audio_toggle,
    },
    {
      image = images.imageFromText("C", "Camera"),
      press_callback = zoom_actions.camera_toggle,
    },
    {
      image = images.imageFromText("S", "Share"),
      press_callback = zoom_actions.share_toggle,
    },
    {
      image = images.imageFromText("X", "Leave"),
      press_callback = zoom_actions.leave_meeting_no_prompt,
    },
  },
  -- Layer N - Blank template layer
  blank = {
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
  local button = layers[currentLayer][button_number]
  if button.passthrough then
    button = layers[button.passthrough][button_number]
  end

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
    if button.passthrough then
      button = layers[button.passthrough][idx]
    end

    if button and button.image then
      streamdeckDevice:setButtonImage(idx, button.image)
    else
      streamdeckDevice:setButtonImage(idx, images.blankImage())
    end
  end
end

function streamdeck_init(connected, sd)
  if connected then
    streamdeckDevice = sd
  else
    streamdeckDevice = nil
  end

  streamdeck_changeLayer('default')
  sd:buttonCallback(streamdeck_buttonCallback)
end

hs.streamdeck.init(streamdeck_init)
