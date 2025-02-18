CurrentWeather = 'XMAS'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false
local set = false

RegisterNetEvent('vSync:updateSet')
AddEventHandler('vSync:updateSet', function()
    set = true
end)

RegisterNetEvent('vSync:updateSet2')
AddEventHandler('vSync:updateSet2', function()
    set = false
end)

RegisterNetEvent('vSync:updateWeather')
AddEventHandler('vSync:updateWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOvertimePersist(CurrentWeather, 15.0)
            Wait(15000)
        end
        Wait(100) -- Wait 0 seconds to prevent crashing.
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

RegisterNetEvent('vSync:updateTime')
AddEventHandler('vSync:updateTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

RegisterNetEvent('vSync:changeTime')
AddEventHandler('vSync:changeTime', function(time)
    ExecuteCommand(time)
end)

CreateThread(function()
    local hour = 00
    local minute = 00
    while true do
        Wait(200)
        local newBaseTime = baseTime
        if GetGameTimer() - 500  > timer then
            newBaseTime = newBaseTime + 0.25
            timer = GetGameTimer()
        end
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime
        end
        baseTime = newBaseTime

        if not set then
           local years, months, days, hours, minutes, seconds = GetLocalTime()
                hour = hours
                minute = minutes
	            --day = days
	            --month = months
	            --year = years
	            --second = seconds
            NetworkOverrideClockTime(hour, minute, 0)
        else
            hour = math.floor(((baseTime+timeOffset)/60)%24)
            minute = math.floor((baseTime+timeOffset)%60)
            NetworkOverrideClockTime(hour, minute, 0)
        end
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('vSync:requestSync')
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/weather', 'Change the weather.', {{ name="weatherType", help="Available types: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween"}})
    TriggerEvent('chat:addSuggestion', '/time', 'Change the time.', {{ name="hours", help="A number between 0 - 23"}, { name="minutes", help="A number between 0 - 59"}})
    TriggerEvent('chat:addSuggestion', '/freezetime', 'Freeze / unfreeze time.')
    TriggerEvent('chat:addSuggestion', '/freezeweather', 'Enable/disable dynamic weather changes.')
    TriggerEvent('chat:addSuggestion', '/morning', 'Set the time to 09:00')
    TriggerEvent('chat:addSuggestion', '/noon', 'Set the time to 12:00')
    TriggerEvent('chat:addSuggestion', '/evening', 'Set the time to 18:00')
    TriggerEvent('chat:addSuggestion', '/night', 'Set the time to 23:00')
    TriggerEvent('chat:addSuggestion', '/blackout', 'Toggle blackout mode.')
end)

-- Display a notification above the minimap.
local function ShowNotification(text, blink)
    if blink == nil then blink = false end
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(blink, false)
end

RegisterNetEvent('vSync:notify')
AddEventHandler('vSync:notify', function(message, blink)
    ShowNotification(message, blink)
end)
