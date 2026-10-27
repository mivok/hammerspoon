local images = require("streamdeck/images")
local audio_devices = require("audio_devices")

-- Status update callbacks for streamdeck buttons
local status_callbacks = {}

-- Image overlay functions
function status_callbacks.disabledImage(image)
  return images.overlayText(image, "X", {
    textColor = hs.drawing.color.hammerspoon.osx_red,
    fontSize = 90,
    yoffset = 0,
  })
end

function status_callbacks.selectedImage(image)
  return images.overlayText(image, "▢", {
    textColor = hs.drawing.color.hammerspoon.osx_green,
    fontSize = 90,
    yoffset = -5,
  })
end

-- Audio device callbacks
function status_callbacks.audio_device(preset_name)
  return function(button)
    if audio_devices.is_active(preset_name) then
      button.status_image = status_callbacks.selectedImage(button.image)
    else
      button.status_image = nil
    end
  end
end

function status_callbacks.shush(button)
  if hs.audiodevice.defaultInputDevice():muted() then
    button.status_image = status_callbacks.disabledImage(button.image)
  else
    button.status_image = nil
  end
end

return status_callbacks
