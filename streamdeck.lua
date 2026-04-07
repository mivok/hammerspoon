-- Make sure hotkey functions are loaded so we can refer to them as streamdeck
-- callbacks
local streamdeck = require("streamdeck/streamdeck")
local images = require("streamdeck/images")

local actions = require("actions")
local status_callbacks = require("status_callbacks")
local zoom_actions = require("zoom_actions")
local teams_actions = require("teams_actions")
local ptt = require("ptt")

local function app_button(bundleID)
  return {
    image = hs.image.imageFromAppBundle(bundleID),
    press_callback = actions.toggle_application(bundleID),
  }
end

local fullSizeLayers = {
  -- Layer 1 - Main layer
  default = {
    -- Row 1
    {
      image = images.imageFromText("🔒", "", {yoffset=0}),
      press_callback = actions.sleep_screen,
    },
    {
      image = images.imageWithLabel("aws.png", "AWS Login"),
      press_callback = actions.aws_sso_login,
    },
    {
      image = images.overlayText(images.imageFromText("📋", "Get"),
        "<", {
          textColor=hs.drawing.color.hammerspoon.black,
          yoffset=5,
        }),
      press_callback = actions.get_clipboard('personal'),
    },
    {
      image = images.overlayText(images.imageFromText("📋", "Send"),
        ">", {
          textColor=hs.drawing.color.hammerspoon.black,
          yoffset=5,
        }),
      press_callback = actions.send_clipboard('personal'),
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
      press_callback = ptt.ptt_press,
      release_callback = ptt.ptt_release,
      update_callback = status_callbacks.shush,
    },
    {
      image = images.imageFromText('⏮︎ ', 'Prev'),
      press_callback = actions.remote_syskeypress('personal', 'PREVIOUS'),
    },
    {
      image = images.imageFromText('⏯︎ ', 'Play'),
      press_callback = actions.remote_syskeypress('personal', 'PLAY'),
    },
    {
      image = images.imageFromText('⏭︎ ', 'Next'),
      press_callback = actions.remote_syskeypress('personal', 'NEXT'),
    },
    {
      image = images.imageWithLabel("teams_icon.png", "Teams", {scale=0.6}),
      press_callback = streamdeck.changeLayerCallback('teams')
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
      image = images.imageWithLabel("zoom-participants.png", "Participants",
        {scale=0.70}),
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
      update_callback = status_callbacks.audio_headset,
    },
    {
      image = images.imageFromText("🔈", "Speaker"),
      press_callback = actions.audio_speaker,
      update_callback = status_callbacks.audio_speaker,
    },
    {
      image = images.imageFromText("💻", "Laptop Speaker"),
      press_callback = actions.audio_laptop,
      update_callback = status_callbacks.audio_laptop,
    },
    {
      image = images.imageWithLabel("zoom-pause.png", "Share Pause",
        {scale=0.50}),
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
      update_callback = status_callbacks.zoom_mute,
    },
    {
      image = images.imageWithLabel("zoom-camera.png", "Camera", {scale=0.70}),
      press_callback = zoom_actions.camera_toggle,
      update_callback = status_callbacks.zoom_camera,
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

  -- Teams
  teams = {
    -- Row 1
    {
      passthrough = 'zoom'
    },
    { },
    {
      image = images.imageFromText("⤢", "Full Screen"),
      press_callback = teams_actions.full_screen,
    },
    {
    },
    {
    },
    -- Row 2
    {
      passthrough = 'zoom'
    },
    {
      passthrough = 'zoom'
    },
    {

      passthrough = 'zoom'
    },
    {
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
      image = images.imageWithLabel("zoom-mic.png", "Mic", {scale=0.70}),
      press_callback = teams_actions.mic,
    },
    {
      image = images.imageWithLabel("zoom-camera.png", "Camera", {scale=0.70}),
      press_callback = teams_actions.camera,
    },
    {
      image = images.imageWithLabel("zoom-share.png", "Share", {scale=0.70}),
      press_callback = teams_actions.share,
    },
    {
      image = images.imageFromText("x", "Leave",
        {textColor=hs.drawing.color.hammerspoon.osx_red}),
      press_callback = teams_actions.leave,
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

local miniLayers = {
  -- Stream Deck Mini: 2 rows by 3 columns.
  default = {
    -- Row 1
    {},
    {},
    {},
    -- Row 2
    {},
    {},
    {},
  },

  blank = {
    -- Row 1
    {},
    {},
    {},
    -- Row 2
    {},
    {},
    {},
  },
}

streamdeck.init({
  ["5x3"] = {
    layers = fullSizeLayers,
    defaultLayer = "default",
  },
  ["3x2"] = {
    layers = miniLayers,
    defaultLayer = "default",
  },
})
