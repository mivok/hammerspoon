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

-- Away/back
function actions.slack_away()
    hs.alert.show("Away")
    hs.task.new(os.getenv("HOME") .. "/bin/awayback.sh", nil, {"away"}):start()
end

function actions.slack_back()
    hs.alert.show("Back")
    hs.task.new(os.getenv("HOME") .. "/bin/awayback.sh", nil, {"back"}):start()
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

return actions
