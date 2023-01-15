local isBWVOn = false
local isShowingAxon = false
local isShowingReveal = false
local record = false

RegisterCommand("bodycam", function(source, args, rawCommand)

        local ped = PlayerPedId()

        while ( not HasAnimDictLoaded( "clothingtie" ) ) do
            RequestAnimDict( "clothingtie" )
            Citizen.Wait( 0 )
        end

        ClearPedTasks(ped)
        TaskPlayAnim(ped, "clothingtie", "outro", 8.0, 2.0, 1880, 51, 2.0, 0, 0, 0 )

        if isBWVOn then
            StopRecordingAndSaveClip()
            Citizen.Wait(2000)
            Notify("~w~{~y~AXON~w~} ~b~Bodycam:~w~ Axon Body Camera turned ~r~off~w~.")
            PlaySoundFrontend(-1, "ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
            TriggerEvent('IFS:PlaySound', Config.Model .. '_out')
        elseif record == true then
            StartRecording(1)
            Citizen.Wait(2000)
            Notify("~w~{~y~AXON~w~} ~b~Bodycam:~w~ Axon Body Camera turned ~g~on~w~.")
            PlaySoundFrontend(-1, "5_SEC_WARNING","HUD_MINI_GAME_SOUNDSET", 1)
            TriggerEvent('IFS:PlaySound', Config.Model .. '_in')
        elseif record == false then
            Citizen.Wait(2000)
            Notify("~w~{~y~AXON~w~} ~b~Bodycam:~w~ Axon Body Camera turned ~g~on~w~.")
            PlaySoundFrontend(-1, "5_SEC_WARNING","HUD_MINI_GAME_SOUNDSET", 1)
            TriggerEvent('IFS:PlaySound', Config.Model .. '_in')
        end

        isBWVOn = not isBWVOn

end,false)

function Notify(string) 
    SetNotificationTextEntry("STRING") 
    AddTextComponentString(string) 
    DrawNotification(false, true) 
end

RegisterKeyMapping("bodycam", "Toggle ~y~Axon ~w~Bodycam", "keyboard", "O")
RegisterCommand("togglerec", function(source, args, rawCommand)
    record = not record
    if record == false then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"Bodycam", "Bodycam recording set to ^1 false"}
          })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"Bodycam", "Bodycam recording set to ^2 true"}
          })
    end
      
end,false)

AddEventHandler('IFS:PlaySound', function(soundFile)
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = Config.soundVolume
        })

end)

Citizen.CreateThread(function()
    while true do

            if isBWVOn then
                local year, month, day, hour, minute, second = GetLocalTime()

                if month < 10 then

                    month = "0" .. month

                end

                if day < 10 then

                    day = "0" .. day

                end

                if not isShowingAxon and Config.Model == 'axon' then
                    SendNUIMessage({
                        transactionType     = 'showAxon',
                        show     = true,
                        timestamp = year .. '-0' .. month .. '-' .. day .. ' ' .. 'T' .. hour .. ':' .. minute .. ':' .. second,
                    })
                    isShowingAxon = true
                end

                if not isShowingReveal and Config.Model == 'reveal' then
                    SendNUIMessage({
                        transactionType     = 'showReveal',
                        show     = true,
                        timestamp = year .. '/' .. month .. '/' .. day .. ' ' .. hour .. ':' .. minute .. ':' .. second,
                    })
                    isShowingReveal = true
                end

                if Config.Model == 'axon' then
                    SendNUIMessage({
                        transactionType     = 'updateTime',
                        timestamp = year .. '-' .. month .. '-' .. day .. ' ' .. 'T' .. hour .. ':' .. minute .. ':' .. second,
                    })
                else
                    SendNUIMessage({
                        transactionType     = 'updateTime',
                        timestamp = year .. '/' .. month .. '/' .. day .. ' ' .. hour .. ':' .. minute .. ':' .. second,
                    })
                end
            else
                if isShowingAxon and Config.Model == 'axon' then
                    SendNUIMessage({
                        transactionType     = 'showAxon',
                        show     = false,
                    })
                    isShowingAxon = false
                end

                if isShowingReveal and Config.Model == 'reveal' then
                    SendNUIMessage({
                        transactionType     = 'showReveal',
                        show     = false,
                    })
                    isShowingReveal = false
                end
            end


    Citizen.Wait(100)
    end
end)