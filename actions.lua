-- Actions for hotkeys and streamdeck
local actions = {}

-- Pause key for music
function actions.pause_music()
    -- We can use media keys for spotify and chrome now, and it does the right
    -- thing
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post();
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post();
end

-- Lock screen
function actions.sleep_screen()
    hs.alert.show("Sleep screen")
    hs.task.new("/usr/bin/pmset", nil, {"displaysleepnow"}):start()
end

function actions.reset_mic_volume()
    level = 80
    ad = hs.audiodevice.defaultInputDevice()
    if ad ~= nil then
        oldvol = math.floor(ad:inputVolume())
        ad:setInputVolume(level)
        hs.alert.show("Input volume reset from " .. oldvol .. "% to " .. level .. "%")
    else
        hs.alert.show("No input device found")
    end
end

function switch_default_audio_devices(output, input)
    outdev = hs.audiodevice.findOutputByName(output)
    indev = hs.audiodevice.findInputByName(input)
    if outdev == nil then
        hs.alert.show("Unable to find output device: " .. output)
        return
    end
    if indev == nil then
        hs.alert.show("Unable to find input device: " .. input)
        return
    end
    outdev:setDefaultOutputDevice()
    outdev:setDefaultEffectDevice()
    indev:setDefaultInputDevice()
    hs.alert.show("Audio devices switched to " .. output .. ", ".. input)
end

function actions.audio_headset()
    switch_default_audio_devices(
        "CalDigit Thunderbolt 3 Audio",
        "Antlion USB Microphone"
    )
end

function actions.audio_speaker()
    -- Switch audio to speakers
    switch_default_audio_devices(
        "CalDigit Thunderbolt 3 Audio",
        "MacBook Pro Microphone"
    )
end

function actions.audio_laptop()
    -- Switch audio to speakers
    switch_default_audio_devices(
        "MacBook Pro Speakers",
        "MacBook Pro Microphone"
    )
end

function actions.keydown(key)
  return function()
    hs.eventtap.event.newKeyEvent(key, true):post()
  end
end

function actions.keyup(key)
  return function()
    hs.eventtap.event.newKeyEvent(key, false):post()
  end
end

function actions.keypress(key)
  return function()
    actions.keydown(key)()
    actions.keyup(key)()
  end
end

function actions.syskeydown(key)
  return function()
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
  end
end

function actions.syskeyup(key)
  return function()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
  end
end

function actions.syskeypress(key)
  return function()
    actions.syskeydown(key)()
    actions.syskeyup(key)()
  end
end

function actions.toggle_application(bundleID)
  return function()
    local app = hs.application.get(bundleID)
    if app == nil then
        hs.application.open(bundleID)
        return
    end
    if app:isRunning() then
        if app:isFrontmost() then
            app:hide()
        else
            hs.application.open(bundleID)
            app:activate()
        end
    else
        hs.application.open(bundleID)
    end
  end
end

function actions.saml2aws_login()
  hs.notify.show("Saml2aws login", "", "Running saml2aws", "")
  hs.task.new('/usr/local/bin/saml2aws', function(exitcode, stdout, stderr)
    local msg = {}
    if exitcode ~= 0 then
      table.insert(msg, "ERROR: exit code " .. exitcode)
    end
    if stdout ~= "" then
      table.insert(msg, (stdout:gsub("^%s*(.-)%s*$", "%1")))
    end
    if stderr ~= "" then
      table.insert(msg, (stderr:gsub("^%s*(.-)%s*$", "%1")))
    end
    hs.notify.show("Saml2aws login", "", table.concat(msg, "\n\n"), "")
  end, {'login', '--skip-prompt'}):start()
end

return actions
