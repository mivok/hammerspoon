local images = require("streamdeck/images")

-- Status update callbacks for streamdeck buttons
local status_callbacks = {}
function status_callbacks.audio_device(button, output, input)
  if hs.audiodevice.defaultInputDevice():name() == input and
    hs.audiodevice.defaultOutputDevice():name() == output then
    button.status_image = status_callbacks.selectedImage(button.image)
  else
    button.status_image = nil
  end
end

function status_callbacks.selectedImage(image)
  return images.overlayText(image, "▢",
  {textColor=hs.drawing.color.hammerspoon.osx_green,
  fontSize=90,
  yoffset=-5})
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

return status_callbacks
