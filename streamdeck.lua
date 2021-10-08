-- Make sure hotkey functions are loaded so we can refer to them as streamdeck
-- callbacks
local streamdeck = require("streamdeck/streamdeck")
local images = require("streamdeck/images")
local actions = require("actions")
local zoom_actions = require("zoom_actions")

function app_button(bundleID)
  return {
    image = hs.image.imageFromAppBundle(bundleID),
    press_callback = actions.toggle_application(bundleID),
  }
end

local layers = {
  -- Layer 1 - Main layer
  default = {
    -- Row 1
    {
      image = images.imageFromText("🔒", "", {yoffset=0}),
      press_callback = actions.sleep_screen,
    },
    {
      image = images.imageWithLabel("aws.png", "AWS Login"),
      press_callback = actions.saml2aws_login,
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
      press_callback = streamdeck.changeLayerCallback('layer2')
    },
    -- Row 2
    {},
    {},
    {},
    {},
    {
      image = images.imageWithLabel("zoom.png", "Zoom", {scale=0.6}),
      press_callback = streamdeck.changeLayerCallback('zoom')
    },
    -- Row 3
    {
      image = images.imageWithLabel('shush.png', 'Shush', {
        scale = 0.75, yoffset = 10}),
      press_callback = actions.keydown("F13"),
      release_callback = actions.keyup("F13"),
    },
    {
      image = images.imageFromText('⏮︎ ', 'Prev'),
      press_callback = actions.syskeydown("PREVIOUS"),
      release_callback = actions.syskeyup("PREVIOUS"),
    },
    {
      image = images.imageFromText('⏯︎ ', 'Play'),
      press_callback = actions.syskeydown("PLAY"),
      release_callback = actions.syskeyup("PLAY"),
    },
    {
      image = images.imageFromText('⏭︎ ', 'Next'),
      press_callback = actions.syskeydown("NEXT"),
      release_callback = actions.syskeyup("NEXT"),
    },
    {
      image = images.imageFromText("3", "Layer"),
      press_callback = streamdeck.changeLayerCallback('layer3')
    },
  },

  -- Layer 2 - Extras
  layer2 = {
    -- Row 1
    {},
    {},
    {},
    {},
    {
      image = images.imageFromText("<", "Back"),
      press_callback = streamdeck.changeLayerCallback('default')
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
    app_button('com.apple.MobileSMS'),
    app_button('com.google.Chrome'),
    app_button('com.kapeli.dashdoc'),
    app_button('com.tinyspeck.slackmacgap'),
  },

  -- Zoom Layer
  zoom = {
    -- Row 1
    {
      image = images.imageFromText("🔉", "Mic Vol"),
      press_callback = actions.reset_mic_volume
    },
    {
      image = images.imageFromText("⎚", "View"),
      press_callback = zoom_actions.toggle_view,
    },
    {
      image = images.imageFromText("⤢", "Full Screen"),
      press_callback = zoom_actions.toggle_full_screen,
    },
    {
      image = images.imageWithLabel("zoom-participants.png", "Participants", {scale=0.70}),
      press_callback = zoom_actions.show_participants,
    },
    {
      image = images.imageWithLabel("zoom-chat.png", "Chat", {scale=0.70}),
      press_callback = zoom_actions.show_chat,
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
    {
      image = images.imageWithLabel("zoom-pause.png", "Share Pause", {scale=0.50}),
      press_callback = zoom_actions.share_pause,
    },
    {
      image = images.imageFromText("<", "Back"),
      press_callback = streamdeck.changeLayerCallback('default')
    },
    -- Row 3
    {
      -- Shush
      passthrough = 'default'
    },
    {
      image = images.imageWithLabel("zoom-mic.png", "Mute", {scale=0.70}),
      press_callback = zoom_actions.audio_toggle,
    },
    {
      image = images.imageWithLabel("zoom-camera.png", "Camera", {scale=0.70}),
      press_callback = zoom_actions.camera_toggle,
    },
    {
      image = images.imageWithLabel("zoom-share.png", "Share", {scale=0.70}),
      press_callback = zoom_actions.share_toggle,
    },
    {
      image = images.imageFromText("x", "Leave",
        {textColor=hs.drawing.color.hammerspoon.osx_red}),
      press_callback = zoom_actions.leave_meeting_no_prompt,
    },
  },

  -- Layer 3
  layer3 = {
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
    {
      image = images.imageFromText("<", "Back"),
      press_callback = streamdeck.changeLayerCallback('default')
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

streamdeck.init(layers)
