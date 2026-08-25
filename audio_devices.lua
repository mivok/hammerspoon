local audio_devices = {}

local presets = {
  headset = {
    output = "USB Audio CODEC",
    input = "MacBook Pro Microphone",
  },
  laptop = {
    output = "MacBook Pro Speakers",
    input = "MacBook Pro Microphone",
  },
}

local function get_preset(name)
  local preset = presets[name]
  if preset == nil then
    hs.alert.show("Unknown audio preset: " .. name)
  end
  return preset
end

function audio_devices.activate(name)
  local preset = get_preset(name)
  if preset == nil then
    return
  end

  local output_device = hs.audiodevice.findOutputByName(preset.output)
  local input_device = hs.audiodevice.findInputByName(preset.input)
  if output_device == nil then
    hs.alert.show("Unable to find output device: " .. preset.output)
    return
  end
  if input_device == nil then
    hs.alert.show("Unable to find input device: " .. preset.input)
    return
  end

  output_device:setDefaultOutputDevice()
  output_device:setDefaultEffectDevice()
  input_device:setDefaultInputDevice()
  hs.alert.show(
    "Audio devices switched to " .. preset.output .. ", " .. preset.input
  )
end

function audio_devices.is_active(name)
  local preset = get_preset(name)
  if preset == nil then
    return false
  end

  local input_device = hs.audiodevice.defaultInputDevice()
  local output_device = hs.audiodevice.defaultOutputDevice()
  return input_device ~= nil and output_device ~= nil and
    input_device:name() == preset.input and
    output_device:name() == preset.output
end

return audio_devices
