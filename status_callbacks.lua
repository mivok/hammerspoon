local images = require("streamdeck/images")

-- Status update callbacks for streamdeck buttons
local status_callbacks = {}

-- Image overlay functions
function status_callbacks.disabledImage(image)
  return images.overlayText(image, "X",
  {textColor=hs.drawing.color.hammerspoon.osx_red,
  fontSize=90,
  yoffset=0})
end

function status_callbacks.selectedImage(image)
  return images.overlayText(image, "▢",
  {textColor=hs.drawing.color.hammerspoon.osx_green,
  fontSize=90,
  yoffset=-5})
end

-- Audio device callbacks
function status_callbacks.audio_device(button, output, input)
  if hs.audiodevice.defaultInputDevice():name() == input and
    hs.audiodevice.defaultOutputDevice():name() == output then
    button.status_image = status_callbacks.selectedImage(button.image)
  else
    button.status_image = nil
  end
end

function status_callbacks.audio_headset(button)
  status_callbacks.audio_device(
    button,
    "CalDigit Thunderbolt 3 Audio",
    "Antlion USB Microphone"
  )
end

function status_callbacks.audio_speaker(button)
  status_callbacks.audio_device(
    button,
    "CalDigit Thunderbolt 3 Audio",
    "MacBook Pro Microphone"
  )
end

function status_callbacks.audio_laptop(button)
  status_callbacks.audio_device(
    button,
    "MacBook Pro Speakers",
    "MacBook Pro Microphone"
  )
end

-- Zoom callbacks
function status_callbacks.zoom_menu(button, disabled_menu_item)
  -- disabled menu item should be the item that is shown in the menu when the
  -- relevant button is disabled (e.g. you are muted or the camera is off). If
  -- this menu item is present, then a disabled overlay will be shown over the
  -- icon
  local app = hs.application.find("zoom.us")
  if app and app:findMenuItem(disabled_menu_item) then
    button.status_image = status_callbacks.disabledImage(button.image)
  else
    button.status_image = nil
  end
end

function status_callbacks.zoom_mute(button)
  return status_callbacks.zoom_menu(button, "Unmute Audio")
end

function status_callbacks.zoom_camera(button)
  return status_callbacks.zoom_menu(button, "Start Video")
end

function status_callbacks.shush(button)
  if hs.audiodevice.defaultInputDevice():muted() then
    button.status_image = status_callbacks.disabledImage(button.image)
  else
    button.status_image = nil
  end
end

return status_callbacks
